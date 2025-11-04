Shader "Custom/FullMapsURP"
{
    Properties
    {
        [MainColor]_BaseColor("Base Color", Color) = (1,1,1,1)
        [MainTexture]_BaseMap("Base Map", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _SpecularMap("Specular Map", 2D) = "white" {}
        _AOMap("AO Map", 2D) = "white" {}
        _EmissionMap("Emission Map", 2D) = "black" {}
        _HeightMap("Height Map", 2D) = "black" {}
        _NormalScale("Normal Scale", Range(0,2)) = 1
        _HeightScale("Height Scale", Range(0,0.1)) = 0.05
        _EmissionStrength("Emission Strength", Range(0,5)) = 1
                _Intensity("Global Intensity", Range(0,1)) = 1

    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile _ _ADDITIONAL_LIGHTS

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // =====================================
            // STRUCTS
            // =====================================
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 tangentWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float2 uv : TEXCOORD4;
            };

            // =====================================
            // UNIFORMS
            // =====================================
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float _NormalScale;
                float _HeightScale;
                float _EmissionStrength;
                float _Intensity;

            CBUFFER_END

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
            TEXTURE2D(_SpecularMap); SAMPLER(sampler_SpecularMap);
            TEXTURE2D(_AOMap); SAMPLER(sampler_AOMap);
            TEXTURE2D(_EmissionMap); SAMPLER(sampler_EmissionMap);
            TEXTURE2D(_HeightMap); SAMPLER(sampler_HeightMap);
            float4 _BaseMap_ST;

            // =====================================
            // FUNCIONES AUXILIARES
            // =====================================
            float2 TransformUV(float2 uv)
            {
                return uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
            }

            // =====================================
            // VERTEX SHADER
            // =====================================
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);

                float3 tWS = TransformObjectToWorldDir(IN.tangentOS.xyz);
                float3 bWS = cross(OUT.normalWS, tWS) * IN.tangentOS.w;

                OUT.tangentWS = tWS;
                OUT.bitangentWS = bWS;
                OUT.uv = TransformUV(IN.uv);
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            // =====================================
            // FRAGMENT SHADER
            // =====================================
            float4 frag(Varyings IN) : SV_Target
            {
                // ---- Parallax simple ----
                float height = SAMPLE_TEXTURE2D(_HeightMap, sampler_HeightMap, IN.uv).r;
                float2 uvParallax = IN.uv + (height - 0.5) * _HeightScale;

                // ---- Muestras de texturas ----
                float3 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvParallax).rgb * _BaseColor.rgb;
                float3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uvParallax), _NormalScale);
                float specular = SAMPLE_TEXTURE2D(_SpecularMap, sampler_SpecularMap, uvParallax).r;
                float ao = SAMPLE_TEXTURE2D(_AOMap, sampler_AOMap, uvParallax).r;
                float3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uvParallax).rgb * _EmissionStrength;

                // ---- Tangent -> World ----
                float3x3 TBN = float3x3(normalize(IN.tangentWS), normalize(IN.bitangentWS), normalize(IN.normalWS));
                float3 N = normalize(mul(TBN, normalTS));

                // ---- Luz principal ----
                Light mainLight = GetMainLight();
                float3 L = normalize(-mainLight.direction);
                float NdotL = saturate(dot(N, L));

                // ---- Difuso, especular y ambiente ----
                float3 diffuse = albedo * mainLight.color * NdotL;
                float3 specularLight = mainLight.color * pow(NdotL, 16.0) * specular;
                float3 ambient = albedo * SampleSH(N) * ao;

                float3 color = (ambient + diffuse + specularLight) * _Intensity + emission * _EmissionStrength;

                return float4(color, 1);
            }

            ENDHLSL
        }
    }

    FallBack Off
}
