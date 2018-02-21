Shader "BruceEvans/8_03_BSC_Effect" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SaturationAmount ("Saturation", Range(0.0, 5)) = 1.0
		_BrightnessAmount ("Brightness", Range (0.0, 1)) = 1.0
		_ContrastAmount ("Constrast", Range(0.0, 5)) = 1.0
	}
	SubShader {
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			fixed _SaturationAmount;
			fixed _BrightnessAmount;
			fixed _ContrastAmount;

			float3 BSC (float3 color, float bright, float sat, float con) {
				float avgLumR = 0.5;
				float avgLumG = 0.5;
				float avgLumB = 0.5;

				float3 lumCoeff = float3(0.2125, 0.7154, 0.0721);

				//brightness
				float3 avgLum = float3(avgLumR, avgLumG, avgLumB);
				float3 brightCol = color * bright;
				float intf = dot(brightCol, lumCoeff);
				float3 intensity = float3(intf, intf, intf);

				//saturation
				float3 saturationCol = lerp(intensity, brightCol, sat);

				//contrast
				float3 conColor = lerp(avgLum, saturationCol, con);
				return conColor;
			}

			fixed4 frag(v2f_img i):COLOR {
				fixed4 renderTex = tex2D(_MainTex, i.uv);

				renderTex.rgb = BSC(renderTex.rgb, _BrightnessAmount, _SaturationAmount, _ContrastAmount);

				return renderTex;
			}

			ENDCG
		}
	}
}
