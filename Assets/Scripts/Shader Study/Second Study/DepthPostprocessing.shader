Shader "Practice/DepthPostprocessing"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        [Header(Wave)]
        _WaveDistance ("Distance from player", Range(0, 0.99)) = 0.5
        _WaveTrail ("Length of the trail", Range(0, 0.99)) = 0.1
        _WaveColor ("Color", Color) = (1,0,0,1)
    }
    SubShader
    {
        // No culling or depth
        // Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _CameraDepthTexture;
            float4 _MainTex_TexelSize;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _WaveDistance;
            float _WaveTrail;
            float4 _WaveColor;
            
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
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // get depth from depth texture
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                // linear depth between camera and far clipping plane
                // 他是把近平面到远平面间的数值映射为0到1
                depth = Linear01Depth(depth);
                // depth as distance from camera in units
                // depth = depth * _ProjectionParams.z;
                float waveFront = step(depth, _WaveDistance);
                float waveTrail = smoothstep(_WaveDistance - _WaveTrail, _WaveDistance, depth);
                float wave = waveFront * waveTrail;

                fixed4 source = tex2D(_MainTex, i.uv);
                fixed4 col = lerp(source, _WaveColor, wave);
                
                return col;
            }
            ENDCG
        }
    }
}
