// Shader URP simple con Lambert + ambiente (SH) usando Normal Map
Shader "Graficos/URP_NormalOnly"
{
    Properties
    {
        [MainColor]_BaseColor("Base Color", Color) = (1,1,1,1)
        [MainTexture]_BaseMap("Albedo (opcional)", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _NormalScale("Normal Scale", Range(0,2)) = 1.0
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 200
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode"="UniversalForward" }
            Cull Back ZWrite On Blend One Zero
            HLSLPROGRAM
            #pragma vertex   vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes { float4 positionOS:POSITION; float3 normalOS:NORMAL; float4 tangentOS:TANGENT; float2 uv:TEXCOORD0; };
            struct Varyings   { float4 positionHCS:SV_POSITION; float3 positionWS:TEXCOORD0; float3 normalWS:TEXCOORD1; float3 tangentWS:TEXCOORD2; float3 bitangentWS:TEXCOORD3; float2 uv:TEXCOORD4; };

            CBUFFER_START(UnityPerMaterial) float4 _BaseColor; float _NormalScale; CBUFFER_END
            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
            float4 _BaseMap_ST, _NormalMap_ST;

            float2 TransformUV(float2 uv, float4 st){ return uv*st.xy + st.zw; }

            Varyings vert(Attributes IN){
                Varyings OUT;
                OUT.positionWS  = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS);
                OUT.normalWS    = TransformObjectToWorldNormal(IN.normalOS);
                float3 tWS = TransformObjectToWorldDir(IN.tangentOS.xyz);
                float3 bWS = cross(OUT.normalWS, tWS)*IN.tangentOS.w;
                OUT.tangentWS=tWS; OUT.bitangentWS=bWS; OUT.uv=IN.uv; return OUT; }

            float3 SampleNormalWS(float2 uv, float3 nWS, float3 tWS, float3 bWS){
                float2 uvN = TransformUV(uv, _NormalMap_ST);
                float3 nTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uvN), _NormalScale);
                float3x3 TBN = float3x3(normalize(tWS), normalize(bWS), normalize(nWS));
                return normalize(mul(TBN, nTS));
            }

            float4 frag(Varyings IN):SV_Target{
                float3 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, TransformUV(IN.uv,_BaseMap_ST)).rgb * _BaseColor.rgb;
                float3 N = SampleNormalWS(IN.uv, IN.normalWS, IN.tangentWS, IN.bitangentWS);
                Light mainLight = GetMainLight(); float3 L = normalize(-mainLight.direction);
                float NdotL = saturate(dot(N,L));
                float3 diffuse = albedo * mainLight.color * NdotL;
                float3 ambient = albedo * SampleSH(N);
                #if defined(_ADDITIONAL_LIGHTS)
                  { uint count=GetAdditionalLightsCount();
                    for(uint i=0u;i<count;i++){ Light l=GetAdditionalLight(i,IN.positionWS);
                      float3 L2=normalize(l.direction); float NdotL2=saturate(dot(N,L2));
                      diffuse += albedo*l.color*(NdotL2*l.distanceAttenuation*l.shadowAttenuation); } }
                #endif
                return float4(ambient+diffuse,1);
            }
            ENDHLSL
        }
    }
    FallBack Off
}