Shader "Custom/TextureAmbient"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Tint Color", Color) = (1,1,1,1)
        _AmbientColor ("Ambient Light", Color) = (0.3, 0.3, 0.3, 1)
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

            // ===== Propiedades =====
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _AmbientColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            // ===== Vertex Shader =====
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // ===== Fragment Shader =====
            fixed4 frag (v2f i) : SV_Target
            {
                // Color base de la textura
                fixed4 texColor = tex2D(_MainTex, i.uv) * _Color;

                // Aplicar iluminación ambiental uniforme
                fixed3 finalColor = texColor.rgb * _AmbientColor.rgb;

                return fixed4(finalColor, texColor.a);
            }
            ENDCG
        }
    }

    FallBack "Unlit/Texture"
}
