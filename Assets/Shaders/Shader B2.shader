Shader "Unlit/ScrollUVExample"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}   // La textura base
        _ScrollDir ("Scroll Direction", Vector) = (0, 0, 0, 0)   // Dirección del desplazamiento (Vector2)
        _Speed ("Scroll Speed", Float) = 0.5     // Velocidad del desplazamiento
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
            float2 _ScrollDir;  // Dirección de desplazamiento
            float _Speed;       // Velocidad de desplazamiento

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv; // Pasamos las coordenadas UV sin transformaciones iniciales
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Desplazamiento de las UV en función del tiempo, dirección y velocidad
                float2 scroll = _ScrollDir * _Speed * _Time.y; // _Time es una variable implícita

                // Aplicamos el desplazamiento a las coordenadas UV
                i.uv += scroll;

                // Respetamos Tiling/Offset de la textura
                i.uv = TRANSFORM_TEX(i.uv, _MainTex);

                // Muestra la textura usando las coordenadas UV desplazadas
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
