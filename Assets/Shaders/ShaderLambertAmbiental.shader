Shader "Custom/LambertAmbient"
{
    Properties
    {
        _Color ("Base Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _AmbientColor ("Ambient Light", Color) = (0.2, 0.2, 0.2, 1)
        _LightDirection ("Light Direction", Vector) = (0, -1, 0, 0)
        _LightColor ("Light Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

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
            float4 _LightColor;
            float4 _LightDirection; // vector de dirección de luz manual

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
            };

            // ===== Vértices =====
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            // ===== Fragmentos =====
            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 N = normalize(i.normalDir);
                fixed3 L = normalize(-_LightDirection.xyz); // dirección de la luz (negativa porque apunta hacia el objeto)

                // Lambert: intensidad = max(0, N · L)
                float NdotL = max(0, dot(N, L));

                // Difuso
                fixed3 diffuse = _LightColor.rgb * NdotL;

                // Ambiental
                fixed3 ambient = _AmbientColor.rgb;

                // Textura base
                fixed3 baseColor = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                // Resultado final
                fixed3 finalColor = baseColor * (diffuse + ambient);

                return fixed4(finalColor, 1.0);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
