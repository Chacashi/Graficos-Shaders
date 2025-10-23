Shader "Unlit/VignetteOnTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}       // Textura base
        _VignetteColor ("Vignette Color", Color) = (0, 0, 0, 1) // Color de la viñeta (negro por defecto)
        _Intensity ("Vignette Intensity", Range(0, 1)) = 0.5   // Intensidad de la viñeta
        _Power ("Vignette Power", Range(0.1, 8)) = 2.0       // Potencia de la viñeta (suavidad)
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
            float4 _VignetteColor;
            float _Intensity;
            float _Power;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);  // Aplica Tiling y Offset de la textura
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Muestreamos la textura base
                fixed4 texColor = tex2D(_MainTex, i.uv);

                // Calculamos la distancia desde el centro (0.5, 0.5) normalizada
                float2 center = float2(0.5, 0.5); // Centro de la textura
                float2 uv = i.uv;
                float dist = distance(uv, center);  // Distancia entre las coordenadas UV y el centro

                // Aplicamos el poder de la viñeta: la distancia se eleva a la potencia deseada
                float vignetteFactor = 1.0 / pow(dist, _Power);

                // Modificamos la viñeta con la intensidad y el color
                vignetteFactor = saturate(vignetteFactor * _Intensity); // Limitar el factor entre 0 y 1

                // La mezcla entre la textura y el color de la viñeta
                fixed4 vignetteColor = lerp(texColor, _VignetteColor, vignetteFactor);

                return vignetteColor;
            }
            ENDCG
        }
    }
}
