Shader "Custom/SnowTrack" {
	Properties {
		_Tess("Tessallation",Range(1,32)) = 4
		_SnowColor("Snow color", Color) = (1,1,1,1)
		_SnowTexture("Snow (RGB)",2D) = "white"{}
		_GroundColor("Ground color", Color) = (1,1,1,1)
		_GroundTexture("Ground (RGB)",2D) = "white"{}
		_Splat("SplatMap",2D) = "black"{}
		_Displacement("Displacement", Range(0,1))=0.5
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
	
		#pragma surface surf Standard fullforwardshadows vertex:disp tessellate:tessDistance

		#pragma target 3.0

#include "Tessellation.cginc"
		struct Input {
			float2 uv_GroundTexture;
			float2 uv_SnowTexture;
			float2 uv_Splat;
		};

		struct appdata {
			float4 vertex: POSITION;
			float4 tangent: TANGENT;
			float3 normal :NORMAL;
			float2 texcoord :TEXCOORD0;
		};
		float _Tess;

		float4 tessDistance(appdata v0, appdata v1, appdata v2) {
			float minDist = 10.0;
			float maxDist = 25.0;
			return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
		}
		sampler2D _Splat;
		float _Displacement;

		void disp(inout appdata v) {
			float d = tex2Dlod(_Splat, float4(v.texcoord.xy, 0, 0)).r* _Displacement;
			v.vertex.xyz -= v.normal*d;
			v.vertex.xyz += v.normal*_Displacement;
		}

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		sampler2D __SnowTexture;
		sampler2D __GroundTexture;
		fixed4 _GroundColor;
		fixed4 _SnowColor;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			half amount = tex2Dlod(_Splat, float4(IN.uv_Splat, 0, 0)).r;
			fixed4 c = lerp(tex2D(__SnowTexture,IN.uv_SnowTexture)*_SnowColor, tex2D(__GroundTexture, IN.uv_GroundTexture)*_GroundColor,amount);
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
