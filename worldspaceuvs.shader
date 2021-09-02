Shader "BeGrid/Tri-Planar" {
  Properties {
		_GridTexture("Grid Texture", 2D) = "white" {}
        _GridColor("Grid Color", Color) = (1, 1, 1, 1)
		_SecondColor("Secondary Color", Color) = (1, 1, 1, 1)
		_Thirdcolor("Tertiary Color", Color) = (1, 1, 1, 1)
		_Blend("Grid Blend", Range(0, 0.5)) = 0.25
		_GridScale ("Grid Scale", Float) = 1
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
	}
	
	SubShader {
		Tags {
			"Queue"="Geometry"
			"IgnoreProjector"="False"
			"RenderType"="Opaque"
		}

		Cull Back
		ZWrite On
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

        fixed4 _GridColor;
		fixed4 _SecondColor;
		fixed4 _Thirdcolor;
        sampler2D _GridTexture;
        half _GridScale;
        half _Smoothness;
		half _Blend;
		
		struct Input {
			half3 worldPos;  // built in
			half3 worldNormal;  // built in
		};

        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

		half3 DyeColors(){

		}
			
		void surf (Input IN, inout SurfaceOutputStandard o) {

			// Find our UVs for each axis based on world position of the fragment.
			half2 yUV = IN.worldPos.xz / _GridScale;
			half2 xUV = IN.worldPos.zy / _GridScale;
			half2 zUV = IN.worldPos.xy / _GridScale;
      
			// Now do texture samples from our diffuse map with each of the 3 UV set's we've just made.
			half3 yDiff = tex2D (_GridTexture, yUV);
			half3 xDiff = tex2D (_GridTexture, xUV);
			half3 zDiff = tex2D (_GridTexture, zUV);

			// Trial and error, no clipping on circles
			half3 blendWeights = pow (abs(IN.worldNormal), 158);
			blendWeights = blendWeights / (blendWeights.x + blendWeights.y + blendWeights.z);

			// Channel Mapping

			half3 finalGrid = xDiff * blendWeights.x + yDiff * blendWeights.y + zDiff * blendWeights.z;

			// main blocks
			half3 gridColors = _GridColor * clamp(finalGrid.b, _Blend, 1);

			// paint white dots (finalGrid.g is mask)
			half invertDots = 1-finalGrid.g;
			// half3 c = invertDots * gridColors;
			half3 c = finalGrid.g * _SecondColor;
			// screen blend mode
			c = 1 - (1-c) * (1-gridColors);
			// c = 1 - (1-_SecondColor) * (1-c);

			// paint red corners
			half3 corners = finalGrid.r * _Thirdcolor;
			c = 1 - (1-corners) * (1 - c);

			// Smoothness
			half3 s = finalGrid.b;

			o.Albedo = c;
            o.Emission = c * 0.75;
			o.Alpha = 1;

            // Roughness
            o.Smoothness = s * _Smoothness;
		} 
		ENDCG
	}
	Fallback "Diffuse"
}