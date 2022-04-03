// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/fish3d raw"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_FlowTex ("FlowTex", 2D) = "black" {}
		_Speed("Speed", Range(0, 1)) = 0.5
		_Intensity("Intensity", Range(0, 2)) = 1

        _dir ("light dir", Vector) = (1, 1, 1, 1) // 光照的方向
        _dis ("shadow dis", range(-10,10)) = 0.5    // 影子的平面 x,z是0,y是这个距离
        _clr ("shadow colour", Color)  =(0.1698113, 0.1698113, 0.1698113, 0.3921569) // 影子颜色
        _offset ("offset", Vector) = (0.03, 0.07, 1, 0) // 偏移
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		Pass {
			ColorMask 0
		}

		// 纯色阴影
        Pass
        {
                        
            Tags { "RenderType"="Transparent" }
            
            BlendOp Min
            Blend One One
            
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

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
            float4 _MainTex_ST;
            float4 _dir;
            float4 _clr;
            float4 _offset;
            float _dis;

            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);

                // 下阴影
                // o.vertex.z = (o.vertex.z)*_dir.z/_dir.y;
                // o.vertex.x = -(o.vertex.x)*_dir.x/_dir.y;
                // o.vertex.y = _dis;
                
                // 描边似的
                // o.vertex.y = (o.vertex.y)*_dir.y/_dir.z;
                // o.vertex.x = (o.vertex.x)*_dir.x/_dir.z;
                // o.vertex.z = _dis;

                // 描边似的
                o.vertex.y = (o.vertex.y)*_dir.y/_dir.z + _offset.y;
                o.vertex.x = (o.vertex.x)*_dir.x/_dir.z + _offset.x;
                o.vertex.z = _dis;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = _clr;

                return col;
            }
            ENDCG
        }

		Pass
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _FlowTex;
			float _Speed;
			float _Intensity;

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 col = tex2D(_MainTex, TRANSFORM_TEX(i.uv, _MainTex));
				col.rgb *= _Color.rgb;
				col.a = _Color.a;

				float4 flow = tex2D(_FlowTex, i.uv + fixed2(_Time.y * _Speed, 0));
				col.rgb += flow.aaa * _Intensity;

				return col;
			}
			ENDCG
		}
	}
}
