Shader "Custom/ToonUnlit"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Base Color", Color) = (1,1,1,1)
        _LightDir ("Light Direction (World)", Vector) = (0,1,1,0)
        _ToonSteps ("Toon Steps", Range(1,8)) = 4
        _UseRamp ("Use Ramp Texture", Float) = 0
        _RampTex ("Ramp Texture", 2D) = "gray" {}

        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0.1,8)) = 3
        _RimIntensity ("Rim Intensity", Range(0,2)) = 1

        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _OutlineWidth ("Outline Width", Range(0,0.05)) = 0.01
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        LOD 200
        Cull Back

        Pass
        {
            Name "ToonUnlitMain"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _Color;
            float4 _LightDir;
            float _ToonSteps;
            float _UseRamp;
            sampler2D _RampTex;

            float4 _RimColor;
            float _RimPower;
            float _RimIntensity;

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
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.viewDir = normalize(_WorldSpaceCameraPos - worldPos);
                return o;
            }

            float QuantizeBands(float v, float steps)
            {
                if (steps <= 1) return v;
                v = saturate(v);
                return floor(v * steps) / (steps - 1);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 N = normalize(i.normal);
                float3 L = normalize(_LightDir.xyz);

                // Base color
                float4 tex = tex2D(_MainTex, i.uv) * _Color;

                // Simulated diffuse
                float NdotL = saturate(dot(N, L));

                float diff = (_UseRamp > 0.5)
                    ? tex2D(_RampTex, float2(NdotL, 0.5)).r
                    : QuantizeBands(NdotL, _ToonSteps);

                // Rim
                float rim = pow(1.0 - saturate(dot(i.viewDir, N)), _RimPower) * _RimIntensity;

                float3 color = tex.rgb * diff + _RimColor.rgb * rim;
                return float4(color, tex.a);
            }
            ENDCG
        }

        // Outline pass
        Pass
        {
            Name "Outline"
            Cull Front
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma vertex vertOutline
            #pragma fragment fragOutline
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            float4 _OutlineColor;
            float _OutlineWidth;

            v2f vertOutline(appdata v)
            {
                v2f o;
                float3 norm = normalize(v.normal);
                float4 pos = v.vertex + float4(norm * _OutlineWidth, 0);
                o.pos = UnityObjectToClipPos(pos);
                return o;
            }

            fixed4 fragOutline(v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
    }

    FallBack Off
}
