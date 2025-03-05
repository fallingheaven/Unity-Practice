Shader "Practice/EmptyForStencilBuffer"
{
    Properties
    {
        [IntRange] _StencilRef ("Stencil Reference Value", Range(0,255)) = 0
    }
    SubShader
    {
        // "Queue"tag中不能有空格，即不能写成"Geometry - 1"
        Tags { "RenderType"="Opaque" "Queue" = "Geometry-1"}
        LOD 100

        Pass
        {
            Blend Zero One
            // 取消z缓冲可以防止在其后的物体被取消绘制
            ZWrite Off
            
            Stencil{
                Ref [_StencilRef]
                Comp Always
                /*
                这里Pass是用来选择对buffer中对应值的value怎么处理的
                关于Pass的参数使用
                Keep	0	Keep the current contents of the stencil buffer.
                Zero	1	Write 0 into the stencil buffer.
                Replace	2	Write the reference value into the buffer.
                IncrSat	3	Increment the current value in the buffer. If the value is 255 already, it stays at 255.
                DecrSat	4	Decrement the current value in the buffer. If the value is 0 already, it stays at 0.
                Invert	5	Negate all the bits of the current value in the buffer.
                IncrWrap	6	Increment the current value in the buffer. If the value is 255 already, it becomes 0.
                DecrWrap	7	Decrement the current value in the buffer. If the value is 0 already, it becomes 255.
                */
                Pass Replace
            }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "HLSLSupport.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.vertex = TransformObjectToHClip(IN.vertex);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {

                return 0;
            }
            ENDHLSL
        }
    }
}
