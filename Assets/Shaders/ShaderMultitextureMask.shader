Shader "Custom/MultitextureMask_Tiling"
{
    Properties
    {
        _MainTex("Base Texture", 2D) = "white" {}
        _SecondTex("Second Texture", 2D) = "white" {}
        _Mask("Mask (Grayscale)", 2D) = "gray" {}
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
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _SecondTex;
            sampler2D _Mask;

            float4 _MainTex_ST;
            float4 _SecondTex_ST;
            float4 _Mask_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uvMain : TEXCOORD0;
                float2 uvSecond : TEXCOORD1;
                float2 uvMask : TEXCOORD2;
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // Aplicar tiling y offset automáticos
                o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvSecond = TRANSFORM_TEX(v.uv, _SecondTex);
                o.uvMask = TRANSFORM_TEX(v.uv, _Mask);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 texA = tex2D(_MainTex, i.uvMain);
                fixed4 texB = tex2D(_SecondTex, i.uvSecond);
                fixed4 mask = tex2D(_Mask, i.uvMask);

                float blend = mask.r;
                return lerp(texA, texB, blend);
            }
            ENDCG
        }
    }
}
