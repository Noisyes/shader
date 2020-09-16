﻿Shader "Chapter 12/Bloom"
{
    Properties
    {
        _MainTex("Main Tex",2D) = "white"{}
        _BloomTex("Bloom Tex",2D) = "black"{}
        _LuminanceThreshold("_LuminanceThreshold",Float) = 0.5
        _BlurSize("Blur Size",Float) = 1.0
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"
        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _BloomTex;
        float _LuminanceThreshold;
        float _BlurSize;
        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOOORD0;
        };
        v2f vertExtractBright(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }
        fixed luminance(fixed4 color)
        {
            return 0.2125*color.r + 0.7154*color.g + 0.0721 * color.b;
        }
        fixed4 fragExtractBright(v2f i) : SV_TARGET
        {
            fixed4 c = tex2D(_MainTex,i.uv);
            fixed val = clamp(luminance(c)-_LuminanceThreshold,0.0,1.0);
            return c * val;
        }
        struct v2fBloom
        {
            float4 pos : SV_POSITION;
            half4 uv : TEXCOOORD0;
        };

        v2fBloom vertBloom(appdata_img v)
        {
            v2fBloom o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv.xy = v.texcoord;
            o.uv.zw = v.texcoord;
            #if UNITY_UV_START_AT_TOP
                if(_MainTex_TexelSize.y < 0.0)
                {
                    o.uv.w = 1.0 - o.uv.w;
                }
            #endif
            return o;
        }
        fixed4 fragBloom(v2fBloom i) : SV_TARGET
        {
            return tex2D(_MainTex,i.uv.xy) + tex2D(_BloomTex,i.uv.zw);
        }
        ENDCG
        Ztest Always
        Cull Off
        ZWrite Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vertExtractBright
            #pragma fragment fragExtractBright
            ENDCG
        }

        UsePass"Chapter 12/GaussianBlur/GAUSSIAN_BLUR_VERTICAL"
        
        UsePass"Chapter 12/GaussianBlur/GAUSSIAN_BLUR_HORIZONTAL"
        Pass
        {
            CGPROGRAM
            #pragma vertex vertBloom
            #pragma fragment fragBloom
            ENDCG
        }
    }
    Fallback Off
}