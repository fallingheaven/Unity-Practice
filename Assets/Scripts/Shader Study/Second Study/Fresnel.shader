Shader "Practice/Fresnel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        [PowerSlider(4)] _Exponent ("Exponent", Range(0.25, 4)) = 1
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

            // #include "UnityCG.cginc"
            #include "HLSLSupport.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(Fresnel)
                float4 _Color;
                float _Exponent;
            CBUFFER_END
            
            struct Attributes
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float3 normalWS : TEXCOORD0;
                float3 faceDir : TEXCOORD1;
                float3 uv : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.vertex = TransformObjectToHClip(IN.vertex);
                OUT.normalWS = TransformObjectToWorld(IN.normal);

                float3 worldPos = TransformObjectToWorld(IN.vertex);
                // 如果这里是worldPos - _WorldSpaceCameraPos，那么后面的朝向自己的向量dot结果就是负数
                // saturate后就是0了，所以看到的就是一个白色（1减后为白色），其实背面渲染是正确的，只是永远看不见
                OUT.faceDir = normalize(_WorldSpaceCameraPos - worldPos);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                // sample the texture
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);

                // saturate将值约束到0~1
                float fresnel = 1 - saturate(dot(IN.normalWS, IN.faceDir));
                col += pow(fresnel, _Exponent) * _Color;

                return col;
            }
            ENDHLSL
        }
    }
}
