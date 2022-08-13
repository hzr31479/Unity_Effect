Shader "Unlit/mosaicShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MosaicSize("Mosaic Size",Range(0.001,0.25)) = 0.005
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // 编译雾效变化时需要
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                //用于传递雾量，数字应为自由纹理坐标值
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _MosaicSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                 /*简单来说，TRANSFORM_TEX主要作用是拿顶点的uv去和材质球的tiling和offset作运算，确保材质球里的缩放和偏移设置是正确的。 （v.texcoord就是顶点的uv）
                而_MainTex_ST的ST是应该是SamplerTexture的意思   就是声明_MainTex是一张采样图，也就是会进行UV运算。如果没有这句话，是不能进行TRANSFORM_TEX的运算的。
                如果Tiling 和Offset你留的是默认值，即Tiling为（1，1） Offset为（0，0）的时候，可以不用
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                换成o.uv = v.texcoord.xy;也是能正常显示的；相当于Tiling 为（1，1）Offset为（0，0）*/
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.uv.x = floor(i.uv.x/_MosaicSize) * _MosaicSize;
                i.uv.y = floor(i.uv.y/_MosaicSize) * _MosaicSize;
                fixed4 col = tex2D(_MainTex,i.uv);
                return col;
            }
            ENDCG
        }
    }
}
