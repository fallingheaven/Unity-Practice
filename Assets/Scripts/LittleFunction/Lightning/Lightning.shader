Shader "Unlit/Lightning"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            // Lightning.compute
            #pragma kernel GeneratePath

            RWStructuredBuffer<float3> Positions;
            float3 StartPos;
            float3 EndPos;
            float Jitter;
            int MaxIterations;

            [numthreads(64,1,1)]
            void GeneratePath (uint3 id : SV_DispatchThreadID)
            {
                if(id.x >= MaxIterations) return;
                
                float3 currentPos = StartPos;
                float3 targetDir = normalize(EndPos - StartPos);
                
                for(int i=0; i<id.x; i++){
                    float3 randomOffset = float3(
                        (frac(sin(i*12.9898)*43758.5453)-0.5)*2,
                        (frac(sin(i*78.233)*12654.1245)-0.5)*2,
                        (frac(sin(i*159.753)*8532.4567)-0.5)*2
                    ) * Jitter;
                    
                    targetDir = normalize(targetDir + randomOffset);
                    currentPos += targetDir * 0.1;
                }
                
                Positions[id.x] = currentPos;
            }
            ENDCG
        }
    }
}