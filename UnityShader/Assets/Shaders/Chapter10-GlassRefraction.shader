// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Chapter 10/GlassRefraction"
{
    Properties
    {
        _MainTex("Main Tex",2D) = "white"{}
        _BumpMap("Bump Map",2D) = "bump"{}
        _CubeMap("Cube Map",Cube) = "_Skybox"{}
        _Distortion("Distortion",Range(0,100)) = 10
        _RefractAmount("Refract Amount",Range(0.0,1)) = 1.0
    }
    SubShader
    {
        Tags{"RenderType" = "Opaque" "Queue"="Transparent"}

        GrabPass{"_RefractionTex"}

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag 
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            //  #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            samplerCUBE _CubeMap;
            float _Distortion;
            fixed _RefractAmount;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;
            
            struct a2v
            {
                float4 vertex : POSITION;
                fixed3 normal : NORMAL;
                fixed4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 scrPos : TEXCOORD1;
                float4 TtoW0 : TEXCOORD2;
                float4 TtoW1 : TEXCOORD3;
                float4 TtoW2 : TEXCOORD4;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.scrPos = ComputeGrabScreenPos(o.pos);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBioNormal = cross(worldNormal,worldTangent) * v.tangent.w;
                o.TtoW0 = float4(worldTangent.x,worldBioNormal.x,worldNormal.x,worldPos.x);
                o.TtoW1 = float4(worldTangent.y,worldBioNormal.y,worldNormal.y,worldPos.y);
                o.TtoW1 = float4(worldTangent.z,worldBioNormal.z,worldNormal.z,worldPos.z);

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
                fixed3 worldViewDir  = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 bump = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.scrPos.xy = offset + i.scrPos.xy;
                fixed3 refrColor = tex2D(_RefractionTex,i.scrPos.xy/i.scrPos.w).rgb;

                bump = normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));
                fixed3 reflectDir = reflect(-worldViewDir,bump);
                fixed4 texColor = tex2D(_MainTex,i.uv.xy);
                fixed3 reflectColor = texCUBE(_CubeMap,reflectDir).rgb * texColor.rgb;
                fixed3 finalColor = reflectColor * (1-_RefractAmount) + refrColor * _RefractAmount;
                return fixed4(finalColor ,1);
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
}
