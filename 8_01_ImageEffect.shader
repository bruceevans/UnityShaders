Shader "BruceEvans/8_01_ImageEffect" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_GrayScale ("Grayscale Amount", Range(0.0, 1)) = 1.0
	}
	SubShader {
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			fixed _GrayScale;

			fixed4 frag(v2f_img i):COLOR {
				fixed4 renderTex = tex2D(_MainTex, i.uv);

				float lum = 0.299 * renderTex.r + 0.587 * renderTex.g + 0.114 * renderTex.b;
				fixed4 finalColor = lerp(renderTex, lum, _GrayScale);

				return finalColor;
			}

			ENDCG
		}
	}
}
