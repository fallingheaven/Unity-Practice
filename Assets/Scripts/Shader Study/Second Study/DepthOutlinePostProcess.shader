Shader "Practice/DepthOutlinePostProcess"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
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

            sampler2D _CameraDepthNormalsTexture;
            float4 _CameraDepthNormalsTexture_TexelSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = v.uv;
                return o;
            }

            float Compare(float baseDepth, float2 uv, float2 neighbor)
            {
                float4 neighborDepthnormal = tex2D(_CameraDepthNormalsTexture, neighbor);
                
                float3 neighborNormal;
                float neighborDepth;
                DecodeDepthNormal(neighborDepthnormal, neighborDepth, neighborNormal);
                neighborDepth = neighborDepth * _ProjectionParams.z;

                return baseDepth - neighborDepth;
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

                float res = 0;
                float offset = 2;
                float offsetCount = 32;
                
                [LOOP]
                for (int _i = 0; _i < offsetCount; _i++)
                {
                    float x = (i.uv + float2(_CameraDepthNormalsTexture_TexelSize.x * offset * sin(_i * UNITY_TWO_PI / offsetCount), 0)).x;
                    float y = (i.uv + float2(0, _CameraDepthNormalsTexture_TexelSize.y * offset * cos(_i * UNITY_TWO_PI / offsetCount))).y;
                    res += Compare(depth, i.uv, float2(x, y));
                }

                // float x = (i.uv + float2(_CameraDepthNormalsTexture_TexelSize.x, 0) * offset).x;
                // float y = (i.uv + float2(0, _CameraDepthNormalsTexture_TexelSize.y) * offset).y;
                // // res += Compare(depth, i.uv, float2(x, y));
                // float4 neighborDepthnormal = tex2D(_CameraDepthNormalsTexture, float2(x, y));
                // float3 neighborNormal;
                // float neighborDepth;
                // DecodeDepthNormal(neighborDepthnormal, neighborDepth, neighborNormal);
                // neighborDepth = neighborDepth * _ProjectionParams.z;
                // res += neighborDepth - depth;
                
                // float4 neighborDepthnormal = tex2D(_CameraDepthNormalsTexture, i.uv + _CameraDepthNormalsTexture_TexelSize.xy * offset);
                //
                // float3 neighborNormal;
                // float neighborDepth;
                // DecodeDepthNormal(neighborDepthnormal, neighborDepth, neighborNormal);
                // neighborDepth = neighborDepth * _ProjectionParams.z;
                //
                // float difference = depth - neighborDepth;
                
                return res;
            }
            ENDCG
        }
    }
}
