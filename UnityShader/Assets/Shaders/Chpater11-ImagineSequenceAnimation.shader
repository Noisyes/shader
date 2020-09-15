Shader "Chapter 11/ImageSequence Animation"
{
    Properties
    {
        _Color("Color Tint",Color)  =(1,1,1,1)
        _MainTex("Main Tex",2D) = "white"{}
        _HorizontalAmount("Horizontal Amount",Float) = 4
        _VerticalAmount("Vertical Amount",Float) = 4
        _Speed("Speed",Float) = 30
    }
    SubShader
    {
        Tags{"RenderType" = "Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True"}
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _HorizontalAmount;
            float _VerticalAmount;
            float _Speed;

            struct a2v
            {
                float4 vertex : POSITION;
                fixed3 normal : NORMAL;
                float4 texcoord : TEXCOORD;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = _MainTex_ST.xy * v.texcoord.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag(v2f i) :SV_TARGET
            {
                float time = _Time.y * _Speed;
                float row = floor(time/_HorizontalAmount);
                float column = time - row * _HorizontalAmount;
                half2 uv = i.uv + half2(row,-column);
                uv.x /= _HorizontalAmount;
                uv.y /= _VerticalAmount;
                fixed4 c = tex2D(_MainTex,uv);
                c.rgb *= _Color.rgb;
                return c;
            }

            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}