Shader "Practice/VFXShader"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcFactor ("SrcFactor", int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstFactor ("DstFactor", int) = 1
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Name "半透明"
        // 排序、渲染类型都设为半透明
        // 对于渲染队列，值越小越先画
        // 对于不透明物体，先画近的再画远的，不渲染被遮挡物体部分
        // 对于透明物体，先画远的再画近的
        Tags {  "Queue" = "Transparent"
                "RenderType"="Transparent"
                "RenderPipeLine" = "UniversalPipeLine"}
        LOD 100
        
        Pass
        {
            // 设定如何组合输出的通道的颜色
            // Blend <source factor> <destination factor>
            // 该形式表示启用混合，设置两个参数
            // FinalColor = (srcFactor * srcColor) + (dstFactor * dstColor)
            // 这里srcFactor对当前颜色进行取值，dstFactor对缓冲区中的颜色（常为其他已渲染的物体等）进行改变
            // One表示叠加，若是Zero就是减法
            Blend [_SrcFactor] [_DstFactor]
            
            // 关闭深度缓冲，若开启，会遮挡后面的物体，后面的物体便不再绘制
            ZWrite Off
            
            // 关闭双面剔除，back就是开启背面剔除，front同理
            Cull off
            
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
                // 获取Properties中的Color字段
                float4 _Color;
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
