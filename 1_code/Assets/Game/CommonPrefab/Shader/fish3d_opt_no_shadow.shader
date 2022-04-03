// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "fish3d_opt_no_shadow"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}

		_Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
		[Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0

		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0

		_BumpScale("Scale", Float) = 1.0
		_BumpMap("Normal Map", 2D) = "bump" {}

		_Occlusion("Occlusion", Range(0.0, 2.0)) = 1
		_Ambient("Ambient", Range(0.0, 2.0)) = 1
		_Atten("Atten", Range(0.0, 2.0)) = 1

		_EmissionColor("EmissionColor", Color) = (0,0,0)
	}

		CGINCLUDE
#define UNITY_SETUP_BRDF_INPUT MetallicSetup

#include "UnityStandardCoreForward.cginc"
		half _Occlusion;
		half _Ambient;
		half _Atten;

		half4 fragBaseOpt(VertexOutputForwardBase i) : SV_Target
		{
			UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

			FRAGMENT_SETUP(s)

			UNITY_SETUP_INSTANCE_ID(i);

			UnityLight mainLight = MainLight();
			UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);
			UnityGI gi = FragmentGI(s, _Occlusion, _Ambient, atten * _Atten, mainLight);

			half4 c = UNITY_BRDF_PBS(s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect);
			c.rgb += Emission(i.tex.xy);

			return OutputForward(c, s.alpha);
		}

		ENDCG

		SubShader
		{
			Tags{ "RenderType" = "Opaque" "IgnoreProjector" = "True" }
				LOD 300

				Pass
			{
				Name "FORWARD"
				Tags { "LightMode" = "ForwardBase" }

				CGPROGRAM
				#pragma target 3.0

				#pragma multi_compile _NORMALMAP
				#pragma multi_compile _EMISSION
				#pragma multi_compile _GLOSSYREFLECTIONS_OFF
				#pragma skip_variants SHADOWS_SOFT DIRLIGHTMAP_COMBINED
				#pragma multi_compile_fwdbase
				#pragma multi_compile_instancing

				#pragma vertex vertBase
				#pragma fragment fragBaseOpt

				ENDCG
			}
		}

		SubShader
		{
			Tags { "RenderType" = "Opaque" "IgnoreProjector" = "True" }
			LOD 150

			Pass
			{
				Name "FORWARD"
				Tags { "LightMode" = "ForwardBase" }

				CGPROGRAM
				#pragma target 2.0

				#pragma multi_compile _NORMALMAP
				#pragma multi_compile _EMISSION
				#pragma multi_compile _GLOSSYREFLECTIONS_OFF
				#pragma skip_variants SHADOWS_SOFT DIRLIGHTMAP_COMBINED
				#pragma multi_compile_fwdbase

				#pragma vertex vertBase
				#pragma fragment fragBaseOpt

				ENDCG
			}
		}
}
