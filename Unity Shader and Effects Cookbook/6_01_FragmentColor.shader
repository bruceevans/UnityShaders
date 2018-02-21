// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "BruceEvans/6_01_FragmentColor" {
	Properties {
		_Color ("Color", Color) = (1, 0, 0, 1)
		_MainTex ("Base texture", 2D) = "white" {}
		//_Normal ("Normal map", 2D) = "bump" {}
	}
	SubShader {

		Pass {

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			//sampler2D _Normal;
			half4 _Color;

			struct vertInput {
				float4 pos:POSITION;
				float2 texcoord:TEXCOORD0;
			};

			struct vertOutput {
				float4 pos:SV_POSITION;
				float2 texcoord:TEXCOORD0;
			};

			vertOutput vert(vertInput input) {
				vertOutput o;
				o.pos = UnityObjectToClipPos(input.pos);
				o.texcoord = input.texcoord;
				return o;
			}

			half4 frag(vertOutput output) : COLOR {
				half4 mainColour = tex2D(_MainTex, output.texcoord);
				return mainColour * _Color;
			}
		ENDCG
		}
	}
}
