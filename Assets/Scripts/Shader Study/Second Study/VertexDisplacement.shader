Shader "Unlit/VertexDisplacement"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Amplitude ("Wave Size", Range(0,1)) = 0.4
        _Frequency ("Wave Freqency", Range(0, 50)) = 2
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(MyBuffer)
                Texture2D _MainTex;
                SamplerState sampler_MainTex;
                float4 _MainTex_ST;
                float _Amplitude;
                float _Frequency;
            CBUFFER_END
            
            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
                float4 normal : NORMAl;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 tangent : TEXCOORD1;
                float4 bitangent : TEXCOORD2;
                float4 normal : TEXCOORD3;
            };

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                float4 vertex = IN.vertex;
                // 一个问题是，我们这样处理后，改变的只是顶点的坐标，法向还是错误的
                // 一个简单的方法是通过周围点计算得到法向
                vertex.y += sin(vertex.x * _Frequency) * _Amplitude;
                OUT.vertex = TransformObjectToHClip(vertex);
                
                OUT.normal = IN.normal;
                OUT.tangent = IN.tangent;
                OUT.bitangent = normalize(dot(OUT.normal, OUT.tangent));

                float4 posPlusTangent = IN.vertex + OUT.tangent;
                float4 posPlusBitangent = IN.vertex + OUT.bitangent;
                posPlusTangent += sin(posPlusBitangent.x * _Frequency) * _Amplitude;
                posPlusBitangent += sin(posPlusBitangent.x + _Frequency) * _Amplitude;

                float4 modifiedTangent = posPlusTangent - IN.vertex;
                float4 modifiedBitangent = posPlusBitangent - IN.vertex;
                OUT.normal = normalize(dot(modifiedTangent, modifiedBitangent));
                
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                // sample the texture
                // half3 lighting = LightingStandard(SurfaceData, GlobalIlluminationData);
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                return col;
            }
            ENDHLSL
        }
    }
}
