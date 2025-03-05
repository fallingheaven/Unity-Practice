Shader "Practice/PolygonClipping"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(MyBuffer)
                Texture2D _MainTex;
                SamplerState sampler_MainTex;
                uniform float2 _corners[1000];
                uniform uint _cornerCount;
            CBUFFER_END
            
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

            
            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.vertex = TransformObjectToHClip(IN.vertex);
                OUT.uv = IN.uv;
                OUT.positionWS = TransformObjectToWorld(IN.vertex);
                return OUT;
            }

            float isLeftOfLine(float2 pos, float2 linePoint1, float2 linePoint2)
            {
                float2 lineDir = linePoint2 - linePoint1;
                
                float2 lineNormal = float2(-lineDir.y, lineDir.x);
                float2 positionVector = pos - linePoint1;

                float toPos = dot(lineNormal, positionVector);

                float side = smoothstep(-0.001, 0.001, toPos);
                
                return side;
            }
            
            half4 frag (Varyings IN) : SV_Target
            {
                float outsideTriangle = 0;

                // 声明进行循环优化，不把循环进行展开
                // 对于循环次数较少的，[unroll]进行展开可以优化效率
                // [loop]
                [unroll]
                for(int index = 0; index < _cornerCount; index++)
                {
                    outsideTriangle += isLeftOfLine(IN.positionWS.xy, _corners[index], _corners[(index+1) % _cornerCount]);
                }

                clip(-outsideTriangle);
                
                return outsideTriangle;
            }
            ENDHLSL
        }
    }
}
