Shader "Unlit/DetailOverlay"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _DetailTex ("Detail Texture", 2D) = "gray" {}
        _DetailBlend ("Detail Blend", Range(0,1)) = 0.5

        _MainTex_ST ("", Vector) = (1,1,0,0)
        _DetailTex_ST ("", Vector) = (1,1,0,0)
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uvMain : TEXCOORD0;
                float2 uvDetail : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _DetailTex;
            float4 _MainTex_ST;
            float4 _DetailTex_ST;
            float _DetailBlend;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                // Tiling y offset independientes
                o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvDetail = TRANSFORM_TEX(v.uv, _DetailTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 baseCol = tex2D(_MainTex, i.uvMain);
                fixed4 detailCol = tex2D(_DetailTex, i.uvDetail);

                // Multiplicación con control de intensidad
                fixed4 detailed = baseCol * lerp(1.0, detailCol, _DetailBlend);

                return detailed;
            }
            ENDCG
        }
    }
}
