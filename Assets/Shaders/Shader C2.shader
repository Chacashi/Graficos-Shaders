Shader "Unlit/MixTextureAndColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}      // Textura base
        _SolidColor ("Solid Color", Color) = (1, 1, 1, 1) // Color sólido para mezclar
        _Mix ("Mix Factor", Range(0, 1)) = 0.5     // Factor de mezcla (0 = solo textura, 1 = solo color)
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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _SolidColor;
            float _Mix;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);  // Aplicamos Tiling y Offset
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Muestreamos la textura base
                fixed4 texColor = tex2D(_MainTex, i.uv);

                // Realizamos la mezcla (lerp) entre la textura y el color sólido
                fixed4 mixedColor = lerp(texColor, _SolidColor, _Mix);

                return mixedColor;
            }
            ENDCG
        }
    }
}
