Shader "Custom/LambertSpecularAmbient"
{
    Properties
    {
        _Color ("Base Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _AmbientColor ("Ambient Light", Color) = (0.2, 0.2, 0.2, 1)
        _LightColor ("Light Color", Color) = (1, 1, 1, 1)
        _LightDirection ("Light Direction", Vector) = (0, -1, -1, 0)
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Shininess ("Shininess", Range(1, 128)) = 32
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 300

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
            fixed4 _LightColor;
            float4 _LightDirection;
            fixed4 _SpecColor;
            float _Shininess;

            // ===== Estructuras =====
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
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            // ===== Vertex Shader =====
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            // ===== Fragment Shader =====
            fixed4 frag (v2f i) : SV_Target
            {
                // Normalizada la normal y direcciones
                float3 N = normalize(i.worldNormal);
                float3 L = normalize(-_LightDirection.xyz); // dirección de la luz (inversa)
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos); // dirección hacia el ojo

                // --- DIFUSA (Lambert) ---
                float NdotL = max(0, dot(N, L));
                float3 diffuse = _LightColor.rgb * NdotL;

                // --- ESPECULAR (Phong clásico) ---
                float3 R = reflect(-L, N); // vector reflejado
                float RdotV = max(0, dot(R, V));
                float3 specular = _SpecColor.rgb * pow(RdotV, _Shininess);

                // --- AMBIENTAL ---
                float3 ambient = _AmbientColor.rgb;

                // --- COLOR BASE ---
                float3 baseColor = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                // --- RESULTADO FINAL ---
                float3 finalColor = baseColor * (ambient + diffuse) + specular;

                return fixed4(finalColor, 1.0);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
