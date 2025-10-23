Shader "Unlit/LerpTwoColors"
{
    Properties
    {
        _ColorA ("Color A", Color) = (1, 0, 0, 1) 
        _ColorB ("Color B", Color) = (0, 0, 1, 1) 
        _Lerp   ("Lerp", Range(0,1)) = 0.5        
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float4 _ColorA;
            float4 _ColorB;
            float _Lerp;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                fixed4 col = lerp(_ColorA, _ColorB, _Lerp);
                return col;
            }
            ENDCG
        }
    }
}
