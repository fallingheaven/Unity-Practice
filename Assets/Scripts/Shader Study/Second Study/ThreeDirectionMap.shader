Shader "Practice/ThreeDirectionMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Sharpness("Blend Sharpness", Range(1, 64)) = 1
    }
    SubShader
    {
        Tags {  "RenderType"="Opaque" 
                "RenderPipeline" = "UniversalPipeline"
                "Queue"="Geometry"}
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(MyBuffer)
                float4 _MainTex_ST;
                float _Sharpness;
            CBUFFER_END
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                float3 normal : NORMAL;
            };

            struct v2f
            {
                // float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                // 引入法线
                float3 normal : NORMAL;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                // float3 worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                float3 worldNormal = mul((float3x3)unity_ObjectToWorld, v.normal);
                o.normal = normalize(worldNormal);
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float2 uv_front = TRANSFORM_TEX(i.worldPos.xy, _MainTex);
                float2 uv_side = TRANSFORM_TEX(i.worldPos.zy, _MainTex);
                float2 uv_top = TRANSFORM_TEX(i.worldPos.xz, _MainTex);
                
                // sample the texture
                half4 col_front = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv_front);
                half4 col_side = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv_side);
                half4 col_top = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv_top);
                // half4 col = (col_front + col_side + col_top) / 3;

                // half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.worldPos.xy);

                float3 weights = i.normal;
                weights = abs(weights);
                weights = pow(weights, _Sharpness);
                weights = weights / (weights.x + weights.y + weights.z);
                

                col_front *= weights.z;
                col_side *= weights.x;
                col_top *= weights.y;

                half4 col = col_front + col_side + col_top;
                
                // return half4(weights, 1);
                return col;
            }
            ENDHLSL
        }
    }
}
