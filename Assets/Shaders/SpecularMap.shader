// URP - Specular Map (Blinn-Phong)
Shader "Graficos/URP_SpecularMap"
{
    Properties
    {
        [MainColor]_BaseColor("Base Color", Color) = (1,1,1,1)
        [MainTexture]_BaseMap("Albedo (opcional)", 2D) = "white" {}
        _SpecMap("Specular Map (RGB)", 2D) = "black" {}
        _SpecColor("Specular Tint", Color) = (1,1,1,1)
        _Shininess("Shininess (Power)", Range(8,256)) = 64
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 250
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

            struct Attributes { float4 positionOS:POSITION; float3 normalOS:NORMAL; float2 uv:TEXCOORD0; };
            struct Varyings   { float4 positionHCS:SV_POSITION; float3 positionWS:TEXCOORD0; float3 normalWS:TEXCOORD1; float2 uv:TEXCOORD2; };

            CBUFFER_START(UnityPerMaterial) float4 _BaseColor; float4 _SpecColor; float _Shininess; CBUFFER_END
            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_SpecMap); SAMPLER(sampler_SpecMap);
            float4 _BaseMap_ST, _SpecMap_ST;

            float2 TransformUV(float2 uv, float4 st){ return uv*st.xy + st.zw; }

            Varyings vert(Attributes IN){
                Varyings OUT; OUT.positionWS=TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS=TransformObjectToHClip(IN.positionOS);
                OUT.normalWS=TransformObjectToWorldNormal(IN.normalOS);
                OUT.uv=IN.uv; return OUT; }

            float4 frag(Varyings IN):SV_Target{
                float3 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, TransformUV(IN.uv,_BaseMap_ST)).rgb * _BaseColor.rgb;
                float3 N = normalize(IN.normalWS);
                Light mainLight = GetMainLight();
                float3 L = normalize(-mainLight.direction);
                float3 V = normalize(_WorldSpaceCameraPos - IN.positionWS);
                float3 H = normalize(L+V);
                float NdotL = saturate(dot(N,L));
                float3 diffuse = albedo * mainLight.color * NdotL;
                float3 ambient = albedo * SampleSH(N);
                float3 specMap = SAMPLE_TEXTURE2D(_SpecMap, sampler_SpecMap, TransformUV(IN.uv,_SpecMap_ST)).rgb;
                float3 specColor = specMap * _SpecColor.rgb;
                float specPow = max(8.0, _Shininess);
                float specTerm = pow(saturate(dot(N,H)), specPow) * NdotL;
                float3 specular = specColor * mainLight.color * specTerm;
                #if defined(_ADDITIONAL_LIGHTS)
                  { uint count=GetAdditionalLightsCount();
                    for(uint i=0u;i<count;i++){ Light l=GetAdditionalLight(i,IN.positionWS);
                      float3 L2=normalize(l.direction), H2=normalize(L2+V);
                      float NdotL2=saturate(dot(N,L2));
                      float specTerm2=pow(saturate(dot(N,H2)), specPow)*NdotL2;
                      diffuse  += albedo   * l.color * (NdotL2*l.distanceAttenuation*l.shadowAttenuation);
                      specular += specColor* l.color * (specTerm2*l.distanceAttenuation*l.shadowAttenuation); } }
                #endif
                return float4(ambient+diffuse+specular,1);
            }
            ENDHLSL
        }
    }
    FallBack Off
}