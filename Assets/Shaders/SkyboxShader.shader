Shader "Unlit/SkyboxShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _LightPos ("LightPos", Range(-1, 1)) = 0.3

        _CloudTex ("CloudTexture", 2D) = "white" {}
        _NoiseTex ("NoiseTexture", 2D) = "white" {}
        _CloudScale ("CloudScale", Vector) = (0.1,0.1,0.03,0.03)
        _DistortTex ("DistortTexture", 2D) = "white" {}

        _HorizonColor ("HorizonColor", Color) = (1,1,1,1)
        _DayTopColor ("DayTopColor", Color) = (1,1,1,1)
        _DayBottomColor ("DayBottomColor", Color) = (1,1,1,1)
        _NightTopColor ("NightTopColor", Color) = (1,1,1,1)
        _NightBottomColor ("NightBottomColor", Color) = (1,1,1,1)
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
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CloudTex;
            sampler2D _NoiseTex;
            sampler2D _DistortTex;

            float _LightPos;
            float3 _HorizonColor;
            float3 _DayTopColor;
            float3 _DayBottomColor;
            float3 _NightTopColor;
            float3 _NightBottomColor;
            float4 _CloudScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float makeCloud(float2 skyuv, float worldPosY, float cutOff, float fuzz)
            {
                float noise = tex2D(_NoiseTex, (skyuv - _Time.x) * _CloudScale.xy);
                float distort = tex2D(_DistortTex, (skyuv + noise - _Time.x) * _CloudScale.zw);
                float base = tex2D(_CloudTex, (skyuv + noise - _Time.x) * _CloudScale.xy);
                float cloud = base * distort;
                cloud = smoothstep(cutOff, cutOff + fuzz, cloud);
                cloud = saturate(cloud) * saturate(worldPosY);
                return cloud;
            }

            float makeAtmosphere()
            {
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 gradientDay = lerp(_DayBottomColor, _DayTopColor, saturate(i.uv.y));
                float3 gradientNight = lerp(_NightBottomColor, _NightTopColor, saturate(i.uv.y));
                float3 skyGradients = lerp(gradientNight, gradientDay, _LightPos);

                float2 skyuv = i.worldPos.xz / i.worldPos.y;

                float horizon = abs(i.uv.y);
                float3 horizonGlow = saturate((1 - horizon)) * _HorizonColor;
                
                float y = i.uv.y;
                float cloud = saturate(makeCloud(skyuv, y, 0.2, 0.3) + makeCloud(skyuv, y, 0.4, 0.15));

                float3 sky = skyGradients + horizonGlow + float3(cloud, cloud, cloud);
                return float4(sky, 1.0);
            }
            ENDCG
        }
    }
}
