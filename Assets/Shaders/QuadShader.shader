Shader "Unlit/QuadShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Off
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

            float gt_tonemapping(float x)
            {
                float m = 0.22;
                float a = 1.0;
                float c = 1.33;
                float P = 1.0;
                float l = 0.4;
                float l0 = ((P-m)*l) / a;
                float S0 = m + l0;
                float S1 = m + a * l0;
                float C2 = (a*P) / (P - S1);
                float L = m + a * (x - m);
                float T = m * pow(x/m, c);
                float S = P - (P - S1) * exp(-C2*(x - S0)/P);
                float w0 = 1 - smoothstep(0.0, m, x);
                float w2 = (x < m+l)?0:1;
                float w1 = 1 - w0 - w2;
                return T * w0 + L * w1 + S * w2;
            }

            float3 gt_tonemapping(float3 col) 
            {
                return float3(gt_tonemapping(col.r), gt_tonemapping(col.g), gt_tonemapping(col.b));
            }

            float3 aces_tonemapping(float3 color)
            {
                const float a = 2.51f;
                const float b = 0.03f;
                const float c = 2.43f;
                const float d = 0.59f;
                const float e = 0.14f;
                return clamp((color * (a * color + b)) / (color * (c * color + d) + e), 0, 1);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                /* col.rgb = aces_tonemapping(col.rgb); */
                return col;
            }
            ENDCG
        }
    }
}
