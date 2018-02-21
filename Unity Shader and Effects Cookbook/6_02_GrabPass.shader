Shader "BruceEvans/6_02_GrabPass" {
	SubShader {

		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque" }
		ZWrite On Lighting Off Cull Off Fog{ Mode Off } Blend One Zero

		GrabPass{ }

		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _GrabTexture;

			struct vertInput {
				float4 vertex:POSITION;
			};

			struct vertOutput {
				float4 vertex:POSITION;
				float4 uvgrab:TEXCOORD1;
			};

			//vertex function
			vertOutput vert(vertInput input) {
				vertOutput o;
				o.vertex = UnityObjectToClipPos(input.vertex);
				o.uvgrab = ComputeGrabScreenPos(o.vertex);
				return o;
			}

			//frag function
			half4 frag(vertOutput i):COLOR {
				fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
				return col + half4(.2, 0, 0, 0);
			}
		ENDCG
		}
	}
}
