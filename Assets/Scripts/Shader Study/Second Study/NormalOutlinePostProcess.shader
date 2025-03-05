Shader "Practice/NormalOutlinePostProcess"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        
        _NormalMult ("Normal Outline Multiplier", Range(0,4)) = 1
        _NormalBias ("Normal Outline Bias", Range(1,4)) = 1
        _DepthMult ("Depth Outline Multiplier", Range(0,4)) = 1
        _DepthBias ("Depth Outline Bias", Range(1,4)) = 1
        
        _NormalThreshold ("Normal Outline Threshold", Range(0, 1)) = 0.5
    }
    SubShader
    {
        

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

            float4 _OutlineColor;
            float _NormalMult;
            float _NormalBias;
            float _DepthMult;
            float _DepthBias;
            float _NormalThreshold;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _CameraDepthNormalsTexture;
            float4 _CameraDepthNormalsTexture_TexelSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            void Compare(inout float depthOutline, inout float normalOutline, float baseDepth, float3 baseNormal, float2 neighbor)
            {
                float4 neighborDepthnormal = tex2D(_CameraDepthNormalsTexture, neighbor);
                
                float3 neighborNormal;
                float neighborDepth;
                DecodeDepthNormal(neighborDepthnormal, neighborDepth, neighborNormal);
                neighborDepth = neighborDepth * _ProjectionParams.z;

                depthOutline += baseDepth - neighborDepth;

                float3 normalDifference = normalize(baseNormal) - normalize(neighborNormal);
                if (length(normalDifference) > _NormalThreshold)
                    normalOutline += normalDifference.r + normalDifference.g + normalDifference.b;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 depthNormal = tex2D(_CameraDepthNormalsTexture, i.uv);

                float3 normal;
                float depth;
                DecodeDepthNormal(depthNormal, depth, normal);
                depth = depth * _ProjectionParams.z;

                float depthOutline = 0;
                float normalOutline = 0;
                float offset = 1;
                float offsetCount = 32;
                
                [LOOP]
                for (int _i = 0; _i < offsetCount; _i++)
                {
                    float x = (i.uv + float2(_CameraDepthNormalsTexture_TexelSize.x * offset * sin(_i * UNITY_TWO_PI / offsetCount), 0)).x;
                    float y = (i.uv + float2(0, _CameraDepthNormalsTexture_TexelSize.y * offset * cos(_i * UNITY_TWO_PI / offsetCount))).y;
                    Compare(depthOutline, normalOutline, depth, normal, float2(x, y));
                }

                depthOutline = depthOutline * _DepthMult;
                depthOutline = saturate(depthOutline);
                depthOutline = pow(depthOutline, _DepthBias);

                normalOutline = normalOutline * _NormalMult;
                normalOutline = saturate(normalOutline);
                normalOutline = pow(normalOutline, _NormalBias);
                
                float outline = normalOutline + depthOutline;
                col = lerp(col, _OutlineColor, outline);
                return col;
            }
            ENDCG
        }
    }
}
