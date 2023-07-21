Shader "Unlit/WaveShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Strength ("Strength", Range(0, 1.0)) = 0.5
        _Speed ("Speed", Range(0.1, 10.0)) = 0.5
        _Radius ("Radius", Float) = 0.5
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Constants.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 local : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Strength;
            float _Speed;
            float _Radius;


            v2f vert (appdata v)
            {
                v2f o;
                o.local = v.vertex;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float tri(float x)
            {
                 return abs(fmod(x, 2.0) - 1.0) - 0.5;
            }

            float truncSine(float x)
            {
                // Half sine wave
                const float height = _Strength;
                const float sineWidth = 0.15;
                
                if(x < 0.0 || x > sineWidth)
                    return 0.0;
                else
                    return sin(x * M_PI / sineWidth) * height;
            }

            float rdWave(float x, float t)
            {
                return truncSine(x - fmod(t * _Speed, 2.0)) * tri(x * 25);
            }

            bool startWave(float x, float y, float time)
            {
                float3 col = float3(0, 0, 0);

                float y_offset = 0;
                y = y - y_offset;
                float thickness = 0.01;

                bool center = y < rdWave(x, time);
                bool right = y < rdWave(x - thickness, time);
                bool left = y < rdWave(x + thickness, time);
                bool top = y + thickness < rdWave(x, time);
                bool bottom = y - thickness < rdWave(x, time);

                return center && !(right && left && top && bottom);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                col = float4(0, 0, 0 ,1.0);

                float x = i.local.x;
                float z = i.local.z;
                if (i.local.z < 0) {
                    x = -x;
                }
                if (i.local.x > 0) {
                    z = -z;
                }

                if (startWave(x + _Radius, i.local.y, _Time.y) && abs(x) < _Radius - 0.001) {
                    col.r = 1.0;
                } else if (startWave(z + _Radius, i.local.y, _Time.y + 1 / _Speed) && abs(z) < _Radius - 0.001) {
                    col.r = 1.0;
                } else {
                    discard;
                }

                return col;
            }
            ENDCG
        }

    }
}
