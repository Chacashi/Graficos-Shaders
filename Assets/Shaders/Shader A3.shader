Shader "Unlit/VignetteEffect"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)      // Color base (centro)
        _VignetteColor ("Vignette Color", Color) = (0, 0, 0, 1) // Color de la viñeta (bordes)
        _Intensity ("Intensity", Range(0, 1)) = 0.5           // Intensidad de la viñeta
        _Power ("Power", Range(0.1, 8)) = 2.0                 // Potencia del borde de la viñeta
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
                float2 uv : TEXCOORD0;
            };

            float4 _BaseColor;
            float4 _VignetteColor;
            float _Intensity;
            float _Power;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Calcular la distancia desde el centro (uv) del objeto
                float2 center = float2(0.5, 0.5); // Centro de la pantalla (UV)
                float dist = distance(i.uv, center);

                // Aplica la viñeta usando una función de suavizado
                float vignette = pow(dist, _Power) * _Intensity;

                // Lerp entre el _BaseColor (centro) y el _VignetteColor (bordes)
                fixed4 col = lerp(_BaseColor, _VignetteColor, vignette);

                return col;
            }
            ENDCG
        }
    }
}
