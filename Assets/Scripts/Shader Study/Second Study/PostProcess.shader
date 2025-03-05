Shader "Practice/PostProcess"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Name "后期处理"
        
        Cull Off
        ZWrite Off
        ZTest Always
        
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(MyBuffer)
                Texture2D _MainTex;
                SamplerState sampler_MainTex;
            
                float4 _MainTex_ST;
            CBUFFER_END
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = v.vertex;
                // o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                // half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                // col = 1 - col;
                half4 col = 1 - i.color;
                return col;
            }
            ENDHLSL
        }
    }
}
