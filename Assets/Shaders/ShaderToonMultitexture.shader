Shader "Custom/ToonMultitextureURP"
{
    Properties
    {
        _BaseTex ("Base Texture", 2D) = "white" {}
        _DetailTex ("Detail Texture", 2D) = "white" {}
        _Mask ("Mask (Grayscale)", 2D) = "white" {}
        _Color ("Main Color", Color) = (1,1,1,1)
        _Steps ("Toon Steps", Range(1,8)) = 4
        _LightDir ("Light Direction", Vector) = (0,1,0,0)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            sampler2D _BaseTex;
            sampler2D _DetailTex;
            sampler2D _Mask;
            float4 _BaseTex_ST;
            float4 _DetailTex_ST;
            float4 _Mask_ST;

            float4 _Color;
            float _Steps;
            float3 _LightDir;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS);
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                // Texturas + máscara
                float2 uvBase = TRANSFORM_TEX(IN.uv, _BaseTex);
                float2 uvDetail = TRANSFORM_TEX(IN.uv, _DetailTex);
                float2 uvMask = TRANSFORM_TEX(IN.uv, _Mask);

                float4 baseCol = tex2D(_BaseTex, uvBase);
                float4 detailCol = tex2D(_DetailTex, uvDetail);
                float mask = tex2D(_Mask, uvMask).r;

                // Combinar por máscara
                float4 colorMix = lerp(baseCol, detailCol, mask) * _Color;

                // Luz tipo toon
                float3 L = normalize(_LightDir);
                float NdotL = saturate(dot(normalize(IN.normalWS), L));

                // Dividir la luz en bandas
                float stepped = floor(NdotL * _Steps) / (_Steps - 1);

                float3 finalColor = colorMix.rgb * stepped;
                return float4(finalColor, 1.0);
            }
            ENDHLSL
        }
    }
}
