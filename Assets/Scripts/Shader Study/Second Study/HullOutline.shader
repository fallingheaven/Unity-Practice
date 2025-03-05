Shader "Practice/HullOutline"
{
    Properties
    {
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineThickness ("Outline Thickness", Range(0, .5)) = 0.1
        
        _Color ("Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
        
        Pass
        {
            // urp中多pass时，第一个用UniversalForward
            Tags{ "LightMode" = "UniversalForward" }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "HLSLSupport.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            CBUFFER_START(MyBuffer)
                Texture2D _MainTex;
                float4 _MainTex_ST;
                SamplerState sampler_MainTex;
            
                float4 _Color;
            CBUFFER_END
            

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.vertex = TransformObjectToHClip(IN.vertex);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                // sample the texture
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                
                col *= _Color;
                return col;
            }
            ENDHLSL
        }
        
        Pass
        {
            // urp中多pass时，第二个用SRPDefaultUnlit
            Tags{ "LightMode" = "SRPDefaultUnlit" }
            
            Cull Front
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "HLSLSupport.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            CBUFFER_START(OutlineBuffer)
                float4 _OutlineColor;
                float _OutlineThickness;
            CBUFFER_END

            struct Attributes
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct Varyings
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                float3 outlineOffset = normalize(IN.normal) * _OutlineThickness;
                OUT.vertex = TransformObjectToHClip(IN.vertex + float4(outlineOffset, 0));
                OUT.normal = TransformObjectToWorld(IN.normal);
                return OUT;
            }
            
            half4 frag (Varyings IN) : SV_Target
            {
                return _OutlineColor;
            }

            ENDHLSL
        }
    }
}
