Shader "BruceEvans/2_02_NormalMap" {
	Properties {
		_MainTint ("Diffuse Tint", Color) = (1, 1, 1, 1)
		_NormalTex ("Normal Map", 2D) = "bump" {}
		_NormalMapIntensity("Normal Intensity", Range(0, 5)) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Lambert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		struct Input {
			float2 uv_NormalTex;
		};

		sampler2D _NormalTex;
		float4 _MainTint;
		float _NormalMapIntensity;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutput o) {

			fixed3 n = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex)).rgb;
			n.x *= _NormalMapIntensity;
			n.y *= _NormalMapIntensity;
			o.Normal = normalize(n);

			//float3 normalMap = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
			//o.Normal = normalMap.rgb;
			o.Albedo = _MainTint.rgb;
		}
		ENDCG
	}

	CustomEditor "NMSlider"
	FallBack "Diffuse"
}
