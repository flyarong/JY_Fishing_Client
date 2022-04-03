// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/fish3d2"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_FlowTex ("FlowTex", 2D) = "black" {}
		_Speed("Speed", Range(0, 1)) = 0.01
		_Intensity("Intensity", Range(0, 2)) = 1
		_OffsetX("OffsetX", Range(-1, 1)) = 0.2
		_OffsetZ("OffsetZ", Range(-1, 1)) = 0.5
	}
	SubShader
	{

		//Tags { "RenderType"="Opaque" }
		Pass {
		Tags { "RenderType"="Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
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
			float _OffsetX;
			float _OffsetZ;

			v2f vert (appdata v)
			{
				v2f o;

				float4 vp = v.vertex;
				vp.x -= _OffsetX;
				vp.z -= _OffsetZ;

				o.pos = UnityObjectToClipPos(vp);
				o.uv = v.uv;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(0.2, 0.2, 0.2, _Color.a);
			}
			ENDCG

		}
		Pass
		{
			Tags { "RenderType"="Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha

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
