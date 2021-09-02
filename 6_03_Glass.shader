Shader "BruceEvans/6_03_Glass" {
	Properties {
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
		_BumpMap ("Noise text", 2D) = "bump" {}
		_Magnitude ("Magnitude", Range(0, 1)) = 0.05
		_Color("Color", Color) = (1, 1, 1, 1)
		_Tile("Tile texture", Range(1, 4)) = 1
	}

	SubShader {

		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		ZWrite On Lighting Off Cull Off Fog{ Mode Off } Blend One Zero

		GrabPass{ }

		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"


			sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D _GrabTexture;
			float _Magnitude;
			fixed4 _Color;
			int _Tile;

			struct vertInput {
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
			};

			struct vertOutput {
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
				float4 uvgrab:TEXCOORD1;
			};

			//vertex function
			vertOutput vert(vertInput input) {
				vertOutput o;
				o.texcoord = input.texcoord;
				o.vertex = UnityObjectToClipPos(input.vertex);
				o.uvgrab = ComputeGrabScreenPos(o.vertex);
				return o;
			}

			//frag function
			half4 frag(vertOutput i):COLOR {
				half4 mainColor = tex2D(_MainTex, i.texcoord * _Tile);
				half4 bump = tex2D (_BumpMap, i.texcoord * _Tile);
				half2 distortion = UnpackNormal(bump).rg; //only red and green?
				i.uvgrab.xy += distortion * _Magnitude;
				fixed4 col = tex2Dproj (_GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
				return col * mainColor * _Color;
			}
		ENDCG
		}
	}
}
