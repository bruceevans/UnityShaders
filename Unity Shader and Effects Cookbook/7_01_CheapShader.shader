Shader "BruceEvans/7_01_CheapShader" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Normal ("Normal Map", 2D) = "bump" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf SimpleLambert exclude_path:prepass noforwardadd

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _Normal;

		struct Input {
			half2 uv_MainTex;
		};

		inline fixed4 LightingSimpleLambert (SurfaceOutput s, fixed3 lightDir, fixed atten) {
			fixed diff = max (0, dot (s.Normal, lightDir));
			fixed4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 2);
			c.a = s.Alpha;
			return c;
		}

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);

			o.Albedo = c.rgb;
			o.Alpha = c.a;
			o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_MainTex));
		}
		ENDCG
	}
	FallBack "Diffuse"
}
