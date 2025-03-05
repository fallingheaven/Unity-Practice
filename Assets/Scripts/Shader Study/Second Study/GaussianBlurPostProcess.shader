Shader "Practice/GaussianBlurPostProcess"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _BlurSize("Blur Size", Range(0, 0.1)) = 0
        [KeywordEnum(GaussLow, GaussHigh)] _Samples ("Sample amount", Float) = 0
        [Toggle(GAUSS)] _Gauss ("Gaussian Blur", float) = 0
        _StandardDeviation("Standard Deviation (Gauss only)", Range(0.001, 0.1)) = 0.02
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
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _SAMPLES_LOW _SAMPLES_MEDIUM _SAMPLES_HIGH
            #pragma shader_feature GAUSS

            #include "UnityCG.cginc"

            #if _SAMPLES_LOW
                #define SAMPLES 10.0f
            #elif _SAMPLES_MEDIUM
                #define SAMPLES 30.0f
            #else
                #define SAMPLES 100.0f
            #endif

            #define PI 3.14159265359
            #define E 2.71828182846
            
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _BlurSize;
            float _StandardDeviation;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            fixed4 frag (Varyings IN) : SV_Target
            {
                // sample the texture
                // fixed4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                fixed4 col = 0;
                float count = 0;
                float invAspect = _ScreenParams.y / _ScreenParams.x;
                
                // 不要用UNITY_LOOP
                [LOOP]
                for (int i = 0; i < SAMPLES; ++i)
                {
                    float2 offset = float2(i / (SAMPLES - 1) - 0.5f, 0) * invAspect * _BlurSize;
                    float2 uv = IN.uv + offset;
                    // 因为这个sprite是精灵图取的，所以uv超出1/0时会取到其他部分的精灵
                    // 但对这个sprite而言，uv的范围还是0~1
                    uv = saturate(uv);
                    
                    // uv = frac(uv);

                    #if !GAUSS
                        col += tex2D(_MainTex, uv);
                        count++;
                    #else
                        float stDevSquared = _StandardDeviation * _StandardDeviation;
                        float gauss = (1 / sqrt(2 * PI * stDevSquared)) * pow(E, -((offset * offset) / (2 * stDevSquared)));
                        col += tex2D(_MainTex, uv) * gauss;
                        count += gauss;
                    #endif
                }
                
                col /= count;
                
                return col;
            }
            ENDCG
        }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _SAMPLES_LOW _SAMPLES_MEDIUM _SAMPLES_HIGH
            #pragma shader_feature GAUSS

            #include "UnityCG.cginc"

            #if _SAMPLES_LOW
                #define SAMPLES 10.0f
            #elif _SAMPLES_MEDIUM
                #define SAMPLES 30.0f
            #else
                #define SAMPLES 100.0f
            #endif

            #define PI 3.14159265359
            #define E 2.71828182846
            
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _BlurSize;
            float _StandardDeviation;

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            fixed4 frag (Varyings IN) : SV_Target
            {
                // sample the texture
                // fixed4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                fixed4 col = 0;
                float count = 0;
                
                // 不要用UNITY_LOOP
                [LOOP]
                for (int i = 0; i < SAMPLES; ++i)
                {
                    float2 offset = float2(0, i / (SAMPLES - 1) - 0.5f) * _BlurSize;
                    float2 uv = IN.uv + offset;
                    // 因为这个sprite是精灵图取的，所以uv超出1/0时会取到其他部分的精灵
                    // 但对这个sprite而言，uv的范围还是0~1
                    // uv = saturate(uv);
                    
                    uv = frac(uv);

                    #if !GAUSS
                        col += tex2D(_MainTex, uv);
                        count++;
                    #else
                        float stDevSquared = _StandardDeviation * _StandardDeviation;
                        float gauss = (1 / sqrt(2 * PI * stDevSquared)) * pow(E, -((offset * offset) / (2 * stDevSquared)));
                        col += tex2D(_MainTex, uv) * gauss;
                        count += gauss;
                    #endif
                }
                
                col /= count;
                
                return col;
            }
            ENDCG
        }
    }
}
