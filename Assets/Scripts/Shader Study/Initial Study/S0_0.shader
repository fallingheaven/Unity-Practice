Shader "Practice/S0_0"
{
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Name "熟悉基本结构"
        // urp下需要设置 "RenderPipeLine" = "UniversalPipeLine"
        Tags { "RenderType"="Opaque" "RenderPipeLine" = "UniversalPipeLine"}
        LOD 100
         
        Pass
        {
            // CG程序开始
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            // #include "UnityCG.cginc"
            #include "HLSLSupport.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(MyBuffer)
                float4 _MainTex_ST;
            CBUFFER_END

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            // 结构体定义传入函数中的参数类型
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            // 结构体定义传入函数中的参数类型
            struct v2f
            {
                float2 uv : TEXCOORD0;
                // UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            

            // 获取Properties中的Color字段
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                // 这个函数的内容是把顶点坐标先乘上世界坐标矩阵，再乘上视图矩阵
                // o.vertex = UnityObjectToClipPos(v.vertex);

                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            // SV_Target = COLOR
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                // 可以通过修改float2 in参数自定义映射关系
                // fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                
                // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col);
                col *= _Color;
                return col;
            }
            ENDHLSL
        }
    }
    
    Fallback "Diffuse - Always visible"
}
