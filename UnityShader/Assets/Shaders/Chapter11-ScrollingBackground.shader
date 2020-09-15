﻿Shader "Chapter 11/ScrollingBackground"
{
    Properties
    {
        _MainTex("Base Layer (RGB)",2D) = "white"{}
        _DetailTex("2nd Layer(RGB)",2D) = "white"{}
        _ScrollX("Base layer Scroll Speed",Float) = 1.0
        _Scroll2X("2nd Layer Scroll",Float) = 1.0
        _Mutiplier("Layer Mutiplier",Float) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DetailTex;
            float4 _DetailTex_ST;
            float _ScrollX;
            float _Scroll2X;
            float _Mutiplier;

            struct a2v
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex) + frac(float2(_ScrollX,0) * _Time.y);
                o.uv.zw = TRANSFORM_TEX(v.texcoord,_DetailTex) + frac(float2(_Scroll2X,0) * _Time.y);
                return o;
            }
            
            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 firstLayer = tex2D(_MainTex,i.uv.xy);
                fixed4 secondLayer = tex2D(_DetailTex,i.uv.zw);
                fixed4 c = lerp(firstLayer,secondLayer,secondLayer.a);
                c.rgb *= _Mutiplier;
                return c;
            }

            ENDCG
        }
    }
    Fallback "VertexLit"
}