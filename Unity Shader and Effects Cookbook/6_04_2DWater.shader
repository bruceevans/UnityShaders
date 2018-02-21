Shader "BruceEvans/6_04_2DWater" {

	Properties {
		_NoiseTex("Noise texture", 2D) = "white" {}
		_Color ("Color", Color) = (1, 1, 1, 1)

		_Period ("Period", Range(0, 50)) = 1
		_Magnitude ("Magnitude", Range(0, 0.5)) = 0.05
		_Scale ("Scale", Range(0, 10)) = 1
	}

	SubShader {

		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		ZWrite On Lighting Off Cull Off Fog{ Mode Off } Blend One Zero

		GrabPass{ "_GrabTexture" }

		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _GrabTexture;

			sampler2D _NoiseTex;
			fixed4 _Color;

			float _Period;
			float _Magnitude;
			float _Scale;

			struct vertInput {
				float4 vertex:POSITION;
				float4 color:COLOR;
				float2 texcoord:TEXCOORD0;
			};

			struct vertOutput {
				float4 vertex:POSITION;
				fixed4 color:COLOR;
				float2 texcoord:TEXCOORD0;

				float4 worldPos:TEXCOORD1;
				float4 uvgrab:TEXCOORD2;
			};

			//vertex function
			vertOutput vert(vertInput input) {
				vertOutput o;
				o.vertex = UnityObjectToClipPos(input.vertex);
				o.color = input.color;
				o.texcoord = input.texcoord;

				o.worldPos = mul(unity_ObjectToWorld, input.vertex);
				o.uvgrab = ComputeGrabScreenPos(o.vertex);

				return o;
			}

			//frag function
			half4 frag(vertOutput i):COLOR {
				float sinT = sin(_Time.w / _Period);
				float2 distortion = float2(
					tex2D(_NoiseTex, i.worldPos.xy / _Scale + float2(sinT, 0)).r - 0.5,
					tex2D(_NoiseTex, i.worldPos.xy / _Scale + float2(0, sinT)).r - 0.5
					);

				i.uvgrab.xy += distortion * _Magnitude;

				fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
				return col * _Color;
			}
		ENDCG
		}
	}
}
