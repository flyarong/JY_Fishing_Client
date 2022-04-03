Shader "fish3d_h"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}

		_Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
		[Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
		_MetallicGlossMap("Metallic", 2D) = "white" {}

		[HideInInspector] _SpecularHighlights("Specular Highlights", Float) = 1.0

		_BumpScale("BumpScale", Float) = 1.0
		_BumpMap("BumpMap", 2D) = "bump" {}

		_LightDir("LightDir", Vector) = (0.3, -8, 1.6, 0)
		_ShadowColor("ShadowColor", Color) = (0.3,0.3,0.3,1)
		_ShadowOffset("ShadowOffset",Range(-20,20)) = 0
		_ShadowDistance("ShadowDistance",Range(-10,10)) = 0

		// Blending state
		[HideInInspector] _Mode("__mode", Float) = 0.0
		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0
	}
	CGINCLUDE
		#pragma target 2.0
		#define UNITY_SETUP_BRDF_INPUT MetallicSetup
		#include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
		};

		half4 _LightDir;
		fixed4 _ShadowColor;
		half _ShadowOffset;
		half _ShadowDistance;

		v2f vert(appdata v)
		{
			v2f o;

			float3 vdir = ObjSpaceViewDir(v.vertex);
			float3 wdir = normalize(_LightDir.xyz);
			vdir *= _ShadowDistance;
			float4 wpos = mul(unity_ObjectToWorld, v.vertex + fixed4(vdir, 0));
			float dis = wpos.z + _ShadowOffset;
			float delta = dis - wpos.z;
			float fac = 1.0 / wdir.z;
			o.pos.x = delta * wdir.x * fac + wpos.x;
			o.pos.y = delta * wdir.y * fac + wpos.y;
			o.pos.z = dis;
			o.pos.w = 1.0;
			o.pos = UnityWorldToClipPos(o.pos.xyz);

			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			return _ShadowColor;
		}
	ENDCG
	SubShader
	{
		LOD 100

		Pass
		{
			Name "FORWARD"
			Tags { "RenderType" = "Opaque" }
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			

			#pragma shader_feature _NORMALMAP
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			#pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
			#pragma skip_variants SHADOWS_SOFT DIRLIGHTMAP_COMBINED
			#pragma multi_compile_fwdbase

			#pragma vertex vertBase
			#pragma fragment fragBase
			#include "UnityStandardCoreForward.cginc"

			ENDCG
		}

		Pass
		{
			ColorMask 0

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			ENDCG
		}
		Pass
		{
			Tags { "RenderType" = "Transparent" }
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			ENDCG
		}
	}
}
