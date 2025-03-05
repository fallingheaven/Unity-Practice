Shader "Practice/S0_1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "PostProcess" "RenderPipeline" = "UniversalPipeline"}
        
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            Name "波浪后期处理"
            HLSLPROGRAM
            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag

            #define FULLSCREEN_SHADERGRAPH

            // #include "UnityCG.cginc"
            #include "HLSLSupport.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex,
                    i.uv + float2(0, cos(_Time.z + i.uv.x * 10) * 0.1));
                // just invert the colors
                col.rgb = 1 - col.rgb;
                return col;
            }
            ENDHLSL
        }
    }
}
