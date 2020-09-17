Shader "Chapter 13/MotionBlurWithDepthTexture"
{
    Properties
    {
        _MainTex("Main Tex",2D) = "white"{}
        _BlurSize("Blur Size",Float) = 1.0
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"
        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepTexture;
        float4x4 _PreviousViewProjectionMatrix;
        float4x4 _CurrentViewProjectionInverseMatrix;
        half _BlurSize;
        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            half2 uv_depth : TEXCOORD1;
        };
        v2f vert(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            o.uv_depth = v.texcoord;
            #if UNIYT_UV_START_AT_TOP
                if(_MainTex_TexelSize.y< 0)
                {
                    o.uv_depth.y = 1- o.uv_depth.y;
                }
            #endif
            return o;
        }
        fixed4 frag(v2f i) : SV_TARGET
        {
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepTexture,i.uv_depth);
            float4 H = float4(i.uv.x * 2 -1,i.uv.y * 2 -1,d * 2 -1,1);
            float4 D = mul(_CurrentViewProjectionInverseMatrix,H);
            float4 worldPos = D/D.w;

            float4 currentPos = worldPos;
            float4 previousePos = mul(_PreviousViewProjectionMatrix,worldPos);
            previousePos/=previousePos.w;

            float2 velocity = (currentPos - previousePos)/2.0f;
            float2 uv = i.uv;
            float3 c = tex2D(_MainTex,uv);
            uv += velocity * _BlurSize;
            for(int i =1; i<3;i++,uv+=velocity * _BlurSize)
            {
                float4 currentColor = tex2D(_MainTex,uv);
                c+=currentColor;
            }
            c/=3;
            return fixed4(c.rgb,1.0);
        }
        ENDCG
        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag
            ENDCG
        }
    }
    Fallback Off
}