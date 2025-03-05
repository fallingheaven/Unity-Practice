Shader "Practice/White Noise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CellSize ("Cell Size", Range(1, 10)) = 1
        [Toggle(CELL)] _Cell ("Cell", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature CELL
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 positionWS : TEXCOORD1;
            };

            Texture2D _MainTex;
            SamplerState sampler_MainTex;
            float4 _MainTex_ST;
            float _CellSize;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.vertex = TransformObjectToHClip(IN.vertex);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.positionWS = TransformObjectToWorld(IN.vertex);
                return OUT;
            }

            float rand1D(float3 vec, float3 randSeed)
            {
                float res = dot(sin(vec), randSeed);
                res = frac(sin(res) * 124563.52256);
                return res;
            }

            float3 rand3D(float3 vec)
            {
                #if CELL
                float3 cell = floor(vec / _CellSize);
                return float3
                (
                    rand1D(cell.x, float3(21.432, 13.5433, 52.56322)),
                    rand1D(cell.y, float3(12.4235, 68.1245, 9.2145)),
                    rand1D(cell.z, float3(54.215, 63.675, 42.6779))
                );
                #else
                return float3
                (
                    rand1D(vec.x, float3(21.432, 13.5433, 52.56322)),
                    rand1D(vec.y, float3(12.4235, 68.1245, 9.2145)),
                    rand1D(vec.z, float3(54.215, 63.675, 42.6779))
                );
                #endif
            }

            float4 frag (Varyings IN) : SV_Target
            {
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                col *= float4(rand3D(IN.positionWS), 1);
                // col *= GenerateHashedRandomFloat(IN.positionWS * 1000);
                return col;
            }
            ENDHLSL
        }
    }
}
