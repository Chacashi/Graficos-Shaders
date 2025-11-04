// URP - Parallax (Height Map) con Lambert + SH
Shader "Graficos/URP_HeightParallax"
{
    Properties
    {
        [MainColor]_BaseColor("Base Color", Color) = (1,1,1,1)
        [MainTexture]_BaseMap("Albedo", 2D) = "white" {}
        _HeightMap("Height Map", 2D) = "black" {}
        _ParallaxScale("Parallax Scale", Range(0,0.06)) = 0.02
        _HeightMid("Height Mid (center)", Range(0,1)) = 0.5
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
            #pragma vertex   vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes { float4 positionOS:POSITION; float3 normalOS:NORMAL; float4 tangentOS:TANGENT; float2 uv:TEXCOORD0; };
            struct Varyings   { float4 positionHCS:SV_POSITION; float3 positionWS:TEXCOORD0; float3 normalWS:TEXCOORD1; float3 tangentWS:TEXCOORD2; float3 bitangentWS:TEXCOORD3; float2 uv:TEXCOORD4; };

            CBUFFER_START(UnityPerMaterial) float4 _BaseColor; float _ParallaxScale; float _HeightMid; CBUFFER_END
            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
            TEXTURE2D(_HeightMap); SAMPLER(sampler_HeightMap);
            float4 _BaseMap_ST, _HeightMap_ST;

            float2 TransformUV(float2 uv,float4 st){ return uv*st.xy + st.zw; }

            float2 ApplyParallax(float2 uv, float3 viewDirWS, float3 nWS, float3 tWS, float3 bWS){
                float3x3 TBN = float3x3(normalize(tWS), normalize(bWS), normalize(nWS));
                float3 viewDirTS = mul(transpose(TBN), normalize(viewDirWS));
                float2 uvH = TransformUV(uv, _HeightMap_ST);
                float h = SAMPLE_TEXTURE2D(_HeightMap, sampler_HeightMap, uvH).r;
                float height = (h - _HeightMid) * _ParallaxScale;
                float denom = max(viewDirTS.z, 0.1);
                float2 offset = (viewDirTS.xy/denom) * height;
                return uv + offset;
            }

            Varyings vert(Attributes IN){
                Varyings OUT;
                OUT.positionWS=TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionHCS=TransformObjectToHClip(IN.positionOS);
                OUT.normalWS=TransformObjectToWorldNormal(IN.normalOS);
                float3 tWS=TransformObjectToWorldDir(IN.tangentOS.xyz);
                float3 bWS=cross(OUT.normalWS,tWS)*IN.tangentOS.w;
                OUT.tangentWS=tWS; OUT.bitangentWS=bWS; OUT.uv=IN.uv; return OUT;
            }

            float4 frag(Varyings IN):SV_Target{
                float2 uv = TransformUV(IN.uv,_BaseMap_ST);
                float3 Vws = _WorldSpaceCameraPos - IN.positionWS;
                uv = ApplyParallax(uv, Vws, IN.normalWS, IN.tangentWS, IN.bitangentWS);
                float3 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).rgb * _BaseColor.rgb;
                float3 N = normalize(IN.normalWS);
                Light mainLight=GetMainLight(); float3 L=normalize(-mainLight.direction);
                float NdotL=saturate(dot(N,L));
                float3 diffuse=albedo*mainLight.color*NdotL;
                float3 ambient=albedo*SampleSH(N);
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