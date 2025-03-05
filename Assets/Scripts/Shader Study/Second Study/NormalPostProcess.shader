Shader "Practice/NormalPostProcess"
{
    Properties
    {
        // 这个纹理用在屏幕空间的话就默认是屏幕画面，不可从外部修改
        _MainTex ("Texture", 2D) = "white" {}
        _RampTex ("RampTexture", 2D) = "white" {}
        _upCutoff ("up cutoff", Range(0,1)) = 0.7
        _topColor ("top color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Cull Off
        ZWrite Off 
        ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
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
            
            sampler2D _MainTex;
            sampler2D _RampTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthNormalsTexture;
            float4x4 _viewToWorld;

            float _upCutoff;
            float4 _topColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex); // 变换uv
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 depthNormal = tex2D(_CameraDepthNormalsTexture, i.uv);
                
                float3 normal;
                float depth;
                DecodeDepthNormal(depthNormal, depth, normal);
                
                // unity_CameraToWorld也是将点从屏幕空间变换为世界空间，但是是左手坐标系，是反的
                // normal = mul(unity_CameraToWorld, normal);
                normal = mul((float3x3)_viewToWorld, normal);
                
                float up = dot(float3(0, 1, 0), normal);
                up = step(_upCutoff, up);
            
                // return up;
                float4 source = tex2D(_RampTex, i.uv);
                float4 col = lerp(source, _topColor, up * _topColor.a);
                return col;
                // return source;
            }
            ENDCG
        }
    }
}
