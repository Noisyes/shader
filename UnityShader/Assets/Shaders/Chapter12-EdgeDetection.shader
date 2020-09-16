Shader "Chapter 12/EdgeDectection"
{
    Properties
    {
        _MainTex("Main Tex",2D) = "white"{}
    }
    SubShader
    {
        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 
            #include "UnityCG.cginc"
            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            float _EdgeOnly;
            float4 _EdgeColor;
            float4 _BackgroundColor;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv[9] : TEXCOORD0;
            };

            fixed luminance(fixed4 color)
            {
                return 0.2125 * color.r + 0.7154 * color.g + .0721 * color.b;
            }

            half Sobel(v2f i)
            {
                const half Gx[9] = {
                    -1,-2,-1,
                    0,0,0,
                    1,2,1
                };
                const half Gy[9] = {
                    -1,0,1,
                    -2,0,2,
                    -1,0,1
                };
                float4 texColor;
                float edgeX = 0;
                float edgeY = 0;

                for(int it = 0; it < 9;it++)
                {
                    texColor = luminance(tex2D(_MainTex,i.uv[it]));
                    edgeX += texColor * Gx[it];
                    edgeY += texColor * Gy[it];
                }
                half edge = 1 - abs(edgeX) - abs(edgeY);
                return edge;
            }

            v2f vert(appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                half2 uv = v.texcoord;
                o.uv[0] = uv + _MainTex_TexelSize * half2(-1,1);
                o.uv[1] = uv + _MainTex_TexelSize * half2(0,1);
                o.uv[2] = uv + _MainTex_TexelSize * half2(1,1);
                o.uv[3] = uv + _MainTex_TexelSize * half2(-1,0);
                o.uv[4] = uv + _MainTex_TexelSize * half2(0,0);
                o.uv[5] = uv + _MainTex_TexelSize * half2(1,0);
                o.uv[6] = uv + _MainTex_TexelSize * half2(-1,-1);
                o.uv[7] = uv + _MainTex_TexelSize * half2(0,-1);
                o.uv[8] = uv + _MainTex_TexelSize * half2(1,-1);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                half edge = Sobel(i);

                fixed4 withEdgeColor = lerp(_EdgeColor,tex2D(_MainTex, i.uv[4]),edge);
                fixed4 onlyEdgeColor = lerp(_EdgeColor,_BackgroundColor,edge);
                return lerp(withEdgeColor,onlyEdgeColor,_EdgeOnly);
            }
            ENDCG
        }
    }
}