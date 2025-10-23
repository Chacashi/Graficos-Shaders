Shader "Unlit/GrayscaleTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}   // La textura base
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
            float4 _MainTex_ST; // Tiling y offset (implícito)

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv; // Pasamos las coordenadas UV sin transformaciones iniciales
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Muestreamos la textura usando las coordenadas UV
                fixed4 col = tex2D(_MainTex, i.uv);

                // Convertir a escala de grises usando luma
                float gray = dot(col.rgb, float3(0.299, 0.587, 0.114));

                // Asignamos el valor de gris a los tres canales
                col.rgb = float3(gray, gray, gray);

                return col;
            }
            ENDCG
        }
    }
}
