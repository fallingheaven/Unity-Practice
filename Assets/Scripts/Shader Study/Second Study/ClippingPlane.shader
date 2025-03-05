Shader "Practice/ClippingPlane"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _CutOffColor ("Cut Off Color", Color) = (1, 1, 1 ,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Off
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "HLSLSupport.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(MyBuffer)
                Texture2D _MainTex;
                float4 _MainTex_ST;
                SamplerState sampler_MainTex;

                float4 _PlanePosition;
                float4 _PlaneNormal;

                float4 _CutOffColor;
            CBUFFER_END
            
            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                // 这个变量会显示当前是正面还是背面
                // bool facing : SV_IsFrontFace;
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
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.positionWS = TransformObjectToWorld(IN.vertex);
                // OUT.facing = IN.facing;
                return OUT;
            }

            float4 frag (Varyings IN, bool isFrontFace : SV_IsFrontFace) : SV_Target
            {
                // sample the texture
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);

                // 此代码和下面的代码可以做到同样效果
                // float onOneSideOfPlane = dot(IN.positionWS - _PlanePosition.xyz, _PlaneNormal.xyz);
                // onOneSideOfPlane += _PlaneNormal.w;
                
                float onOneSideOfPlane = dot(IN.positionWS - _PlanePosition.xyz, _PlaneNormal.xyz);
                clip(onOneSideOfPlane);

                // 映射到0~1（虽然不影响结果）
                float facing = saturate(isFrontFace);

                col = lerp(_CutOffColor, col, facing);
                
                return col;
            }
            ENDHLSL
        }
    }
}
