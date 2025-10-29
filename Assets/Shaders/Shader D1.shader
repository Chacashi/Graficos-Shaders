Shader "Unlit/LerpTwoTextures"
{
    Properties
    {
        _MainTex ("Base Texture (A)", 2D) = "white" {}
        _TexB ("Second Texture (B)", 2D) = "black" {}
        _Blend ("Blend", Range(0,1)) = 0.5

        // Tiling y offset independientes
        _MainTex_ST ("", Vector) = (1,1,0,0)
        _TexB_ST ("", Vector) = (1,1,0,0)
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uvA : TEXCOORD0;
                float2 uvB : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _TexB;
            float4 _MainTex_ST;
            float4 _TexB_ST;
            float _Blend;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                // Aplicar tiling y offset independientes
                o.uvA = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvB = TRANSFORM_TEX(v.uv, _TexB);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 colA = tex2D(_MainTex, i.uvA);
                fixed4 colB = tex2D(_TexB, i.uvB);

                // Lerp entre las dos texturas
                fixed4 col = lerp(colA, colB, _Blend);
                return col;
            }
            ENDCG
        }
    }
}