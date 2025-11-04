// URP - Emissive Map (difuso + ambiente + emisión HDR)
Shader "Graficos/URP_EmissiveMap"
{
    Properties
    {
        [MainColor]_BaseColor("Base Color", Color) = (1,1,1,1)
        [MainTexture]_BaseMap("Albedo (opcional)", 2D) = "white" {}
        _EmissionMap("Emission Map", 2D) = "black" {}
        [HDR]_EmissionColor("Emission Color (HDR)", Color) = (1,1,1,1)
        _EmissionIntensity("Emission Intensity", Range(0,10)) = 1.5
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 230
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }
            Cull Back ZWrite On Blend One Zero
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes{ float4 positionOS:POSITION; float3 normalOS:NORMAL; float2 uv:TEXCOORD0; };
            struct Varyings  { float4 positionHCS:SV_POSITION; float3 positionWS:TEXCOORD0; float3 normalWS:TEXCOORD1; float2 uv:TEXCOORD2; };

            CBUFFER_START(UnityPerMaterial) float4 _BaseColor; float4 _EmissionColor; float _EmissionIntensity; CBUFFER_END
            TEXTURE2D(_BaseMap);     SAMPLER(sampler_BaseMap);
            TEXTURE2D(_EmissionMap); SAMPLER(sampler_EmissionMap);
            float4 _BaseMap_ST, _EmissionMap_ST;

            float2 TransformUV(float2 uv,float4 st){ return uv*st.xy + st.zw; }

            Varyings vert(Attributes IN){
                Varyings OUT; OUT.positionWS=TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS=TransformObjectToHClip(IN.positionOS);
                OUT.normalWS=TransformObjectToWorldNormal(IN.normalOS);
                OUT.uv=IN.uv; return OUT; }

            float4 frag(Varyings IN):SV_Target{
                float3 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, TransformUV(IN.uv,_BaseMap_ST)).rgb * _BaseColor.rgb;
                float3 N = normalize(IN.normalWS);
                Light mainLight=GetMainLight(); float3 L=normalize(-mainLight.direction);
                float NdotL=saturate(dot(N,L));
                float3 diffuse=albedo*mainLight.color*NdotL;
                float3 ambient=albedo*SampleSH(N);
                float3 eMap = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, TransformUV(IN.uv,_EmissionMap_ST)).rgb;
                float3 emission = eMap * _EmissionColor.rgb * _EmissionIntensity;
                #if defined(_ADDITIONAL_LIGHTS)
                  { uint count=GetAdditionalLightsCount();
                    for(uint i=0u;i<count;i++){ Light l=GetAdditionalLight(i,IN.positionWS);
                      float3 L2=normalize(l.direction); float NdotL2=saturate(dot(N,L2));
                      diffuse += albedo*l.color*(NdotL2*l.distanceAttenuation*l.shadowAttenuation); } }
                #endif
                return float4(ambient+diffuse+emission,1);
            }
            ENDHLSL
        }
    }
    FallBack Off
}