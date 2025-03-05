Shader "Practice/Checkerboard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale ("Scale", Range(0.1, 5)) = 1
        _Color1 ("Color1", Color) = (1, 1, 1, 1)
        _Color2 ("Color2", Color) = (0, 0, 0, 1)
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

            // #include "UnityCG.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(myBuffer)
                float4 _MainTex_ST;
                float _Scale;
                float4 _Color1;
                float4 _Color2;
            CBUFFER_END

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 worldPos : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.worldPos = TransformObjectToWorld(v.vertex);
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // int chessboard_x = frac(floor(i.worldPos.x) / 2) * 2;
                // int chessboard_y = frac(floor(i.worldPos.y) / 2) * 2;
                // half4 col = chessboard_x % 2 == chessboard_y % 2? 1: 0;
                
                half4 chessboard = frac(floor(i.worldPos.x / _Scale) / 2 + floor(i.worldPos.y / _Scale) / 2) * 2;
                half4 col = lerp(_Color1, _Color2, chessboard);
                return col;
            }
            ENDHLSL
        }
    }
}
