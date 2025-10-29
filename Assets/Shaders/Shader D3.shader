Shader "Unlit/MaskCutout"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _Mask ("Mask Texture", 2D) = "gray" {}
        _Threshold ("Cutout Threshold", Range(0,1)) = 0.5

        _MainTex_ST ("", Vector) = (1,1,0,0)
        _Mask_ST ("", Vector) = (1,1,0,0)
    }

    SubShader
    {
        Tags 
        { 
            "Queue"="AlphaTest" 
            "RenderType"="TransparentCutout"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uvMain : TEXCOORD0;
                float2 uvMask : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _Mask;
            float4 _MainTex_ST;
            float4 _Mask_ST;
            float _Threshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvMask = TRANSFORM_TEX(v.uv, _Mask);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 baseCol = tex2D(_MainTex, i.uvMain);
                fixed maskVal = tex2D(_Mask, i.uvMask).r;

                // Recorta fragmentos según el valor de la máscara y el umbral
                clip(maskVal - _Threshold);

                return baseCol;
            }
            ENDCG
        }
    }
}
