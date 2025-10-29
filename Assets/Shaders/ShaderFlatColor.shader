Shader "Custom/FlatColor"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _UseVertexColor ("Use Vertex Color (1 = on, 0 = off)", Float) = 0
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

            // Propiedades
            fixed4 _Color;
            float _UseVertexColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color  : COLOR;      // para soporte de vertex colors
                float2 uv     : TEXCOORD0;  // opcional
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 col : COLOR;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // pasar el color al fragment
                o.col = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Si se usan colores por vértice, multiplexar entre _Color y vertex color
                if (_UseVertexColor > 0.5)
                {
                    // multiplicar el color global por el vertex color (puedes cambiar a i.col directamente si prefieres)
                    return _Color * i.col;
                }
                else
                {
                    return _Color;
                }
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}
