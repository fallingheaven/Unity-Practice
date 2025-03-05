Shader "Practice/CustomLighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1, 1, 1, 1)
        _Ramp ("Toon Ramp", 2D) = "white" {}
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

            // #include "HLSLSupport.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(MyBuffer)
                float4 _Color;
                Texture2D _Ramp;
                Texture2D _MainTex;
                SamplerState  sampler_MainTex;
                SamplerState  sampler_Ramp;
            CBUFFER_END
            
            struct Attributes
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD1;
            };

            struct Varyings
            {
                float3 reflectWS : TEXCOORD3;
                float3 viewDir : TEXCOORD1;
                float2 uv : TEXCOORD2;
                float3 normalWS : TEXCOORD0;
                // 这个不能不写
                float4 vertex : SV_POSITION;
            };

            // TEXTURE2D(_MainTex);
            // SAMPLER(sampler_MainTex);

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.vertex = TransformObjectToHClip(IN.vertex);
                OUT.normalWS = normalize(TransformObjectToWorld(IN.normal));
                float3 positionWS = TransformObjectToWorld(IN.vertex);
                
                Light light = GetMainLight();
                OUT.reflectWS = reflect(light.direction, OUT.normalWS);
                OUT.viewDir = normalize(_WorldSpaceCameraPos - positionWS);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                Light light = GetMainLight();
                float intensity = dot(IN.normalWS, light.direction) / 2 + 0.5;
                float3 lightIntensity = SAMPLE_TEXTURE2D(_Ramp, sampler_Ramp, float2(intensity, 0));
                
                // sample the texture
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _Color;
                half3 color = col;
                color *= lightIntensity;
                col.rgb = color;
                col.a = 1;
                
                return col;
            }
            ENDHLSL
        }
    }
}
