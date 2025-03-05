Shader "Practice/SpriteBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        // 模糊效果取样范围
        _BlurSize ("Blur Size", Range(0, 0.01)) = 0
        
        [KeywordEnum(Low, Medium, High)] _Samples ("Sample amount", Float) = 0
        
        // 圆形取样时二次取样的次数
        _CircleBlurAmount ("Circle Blur Amount", Range(1, 20)) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline"}
        LOD 100

        // 开启blend才能绘制透明部分
        Blend SrcAlpha OneMinusSrcAlpha

		ZWrite off
        Cull Off
        
        Pass
        {
            Tags{ "LightMode" = "UniversalForward" }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _SAMPLES_LOW _SAMPLES_MEDIUM _SAMPLES_HIGH

            #include "HLSLSupport.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #if _SAMPLES_LOW
                #define SAMPLES 10.0f
            #elif _SAMPLES_MEDIUM
                #define SAMPLES 30.0f
            #else
                #define SAMPLES 100.0f
            #endif
            
            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            Texture2D _MainTex;
            SamplerState sampler_MainTex;
            float4 _MainTex_ST;
            float _BlurSize;
            int _CircleBlurAmount;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.vertex = TransformObjectToHClip(IN.vertex);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            fixed4 frag (Varyings IN) : SV_Target
            {
                // sample the texture
                // fixed4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                fixed4 col = 0;
                
                // 不要用UNITY_LOOP
                [LOOP]
                for (int i = 0; i < SAMPLES; ++i)
                {
                    float2 offset = float2(sin(TWO_PI / SAMPLES * i), cos(TWO_PI / SAMPLES * i)) * 0.5f * _BlurSize;
                    float2 uv = IN.uv + offset;
                    for (int j = 0; j < _CircleBlurAmount; j++)
                    {
                        float2 _uv = uv + offset * ((float)j / _CircleBlurAmount);
                        // 因为这个sprite是精灵图取的，所以uv超出1/0时会取到其他部分的精灵
                        // 但对这个sprite而言，uv的范围还是0~1
                        _uv = saturate(_uv);
                        col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, _uv) / pow(2, j);
                    }
                }

                float count = 0;
                for (int i = 0; i < _CircleBlurAmount; i++)
                {
                    count += 1 / pow(2, i);
                }
                
                col /= SAMPLES * count;
                
                return col;
            }
            ENDHLSL
        }
//        Pass
//        {
//            Tags{ "LightMode" = "UniversalForward" }
//            
//            HLSLPROGRAM
//            #pragma vertex vert
//            #pragma fragment frag
//            #pragma multi_compile _SAMPLES_LOW _SAMPLES_MEDIUM _SAMPLES_HIGH
//
//            #include "HLSLSupport.cginc"
//            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//
//            #if _SAMPLES_LOW
//                #define SAMPLES 10.0f
//            #elif _SAMPLES_MEDIUM
//                #define SAMPLES 30.0f
//            #else
//                #define SAMPLES 100.0f
//            #endif
//            
//            struct Attributes
//            {
//                float4 vertex : POSITION;
//                float2 uv : TEXCOORD0;
//            };
//
//            struct Varyings
//            {
//                float2 uv : TEXCOORD0;
//                float4 vertex : SV_POSITION;
//            };
//
//            Texture2D _MainTex;
//            SamplerState sampler_MainTex;
//            float4 _MainTex_ST;
//            float _BlurSize;
//
//            Varyings vert (Attributes IN)
//            {
//                Varyings OUT;
//                OUT.vertex = TransformObjectToHClip(IN.vertex);
//                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
//                return OUT;
//            }
//
//            fixed4 frag (Varyings IN) : SV_Target
//            {
//                // sample the texture
//                // fixed4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
//                fixed4 col = 0;
//                float invAspect = _ScreenParams.y / _ScreenParams.x;
//                
//                // 不要用UNITY_LOOP
//                [LOOP]
//                for (int i = 0; i < SAMPLES; ++i)
//                {
//                    float2 uv = IN.uv + float2(i / (SAMPLES - 1) - 0.5f, 0) * _BlurSize * invAspect;
//                    // 因为这个sprite是精灵图取的，所以uv超出1/0时会取到其他部分的精灵
//                    // 但对这个sprite而言，uv的范围还是0~1
//                    uv = saturate(uv);
//                    col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
//                }
//
//                col /= SAMPLES;
//                
//                return col;
//            }
//            ENDHLSL
//        }
//        
//        Pass
//        {
//            Tags{ "LightMode" = "SRPDefaultUnlit" }
//            
//            HLSLPROGRAM
//            #pragma vertex vert
//            #pragma fragment frag
//            #pragma multi_compile _SAMPLES_LOW _SAMPLES_MEDIUM _SAMPLES_HIGH
//            
//            #include "HLSLSupport.cginc"
//            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//
//            #if _SAMPLES_LOW
//                #define SAMPLES 10.0f
//            #elif _SAMPLES_MEDIUM
//                #define SAMPLES 30.0f
//            #else
//                #define SAMPLES 100.0f
//            #endif
//            
//            struct Attributes
//            {
//                float4 vertex : POSITION;
//                float2 uv : TEXCOORD0;
//            };
//
//            struct Varyings
//            {
//                float2 uv : TEXCOORD0;
//                float4 vertex : SV_POSITION;
//            };
//
//            Texture2D _MainTex;
//            SamplerState sampler_MainTex;
//            float4 _MainTex_ST;
//            float _BlurSize;
//
//            Varyings vert (Attributes IN)
//            {
//                Varyings OUT;
//                OUT.vertex = TransformObjectToHClip(IN.vertex);
//                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
//                return OUT;
//            }
//
//            fixed4 frag (Varyings IN) : SV_Target
//            {
//                // sample the texture
//                // fixed4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
//                fixed4 col = 0;
//                
//                // 不要用UNITY_LOOP
//                [LOOP]
//                for (int i = 0; i < SAMPLES; ++i)
//                {
//                    float2 uv = IN.uv + float2(0, i / (SAMPLES - 1) - 0.5f) * _BlurSize;
//                    // 因为这个sprite是精灵图取的，所以uv超出1/0时会取到其他部分的精灵
//                    // 但对这个sprite而言，uv的范围还是0~1
//                    uv = saturate(uv);
//                    col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
//                }
//
//                col /= SAMPLES;
//                
//                return col;
//            }
//            ENDHLSL
//        }
    }
}
