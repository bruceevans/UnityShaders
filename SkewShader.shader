Shader "Cahuitl/Standard_Skew" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_MainNormal ("Normal Map", 2D) = "bump" {}
		_Skew ("Skew Value", Vector) = (0, 0, 0, 0) //hide this?
		_NormalInt ("Normal Intensity", Range(0, 5)) = 1 
	}
	SubShader {

		Tags { "RenderType"="Opaque" }
        LOD 100

		CGPROGRAM
		#pragma surface surf Standard vertex:vert addshadow
			
		sampler2D _MainTex;
		sampler2D _MainNormal;
		float4 _Color;
		fixed4 _Skew;
		float _NormalInt;

		struct Input {
			float2 uv_MainTex;
			float2 uv_MainNormal;
		};

		void vert (inout appdata_full v) {
			//v.vertex.y += _Skew.y * v.vertex.z * v.vertex.y;
			v.vertex.z -= _Skew.z * v.vertex.y;  //here's the magic
			v.vertex.x += _Skew.x * v.vertex.y;  //here's the magic
		}

		void surf(Input IN, inout SurfaceOutputStandard o) {
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex) * _Color;

			//adjust the normals based on a slider
			half3 n = UnpackNormal(tex2D(_MainNormal, IN.uv_MainNormal));
			n.x *= _NormalInt;
			n.y *= _NormalInt;
			o.Normal = n;
		}
		ENDCG
		// Pass to render object as a shadow caster
		Pass {
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
           
			Fog {Mode Off}
			ZWrite On ZTest LEqual Cull Off
			Offset 1, 1
     
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
 
			float4 _QOffset;
			float _Dist;
             
			struct v2f {
				V2F_SHADOW_CASTER;
			};
             
			v2f vert( appdata_base v ) {
				float4 vPos = mul (UNITY_MATRIX_MV, v.vertex);
				float zOff = vPos.z/_Dist;
				vPos += _QOffset*zOff*zOff;
				v.vertex = mul (vPos, UNITY_MATRIX_IT_MV);
				v2f o;
				TRANSFER_SHADOW_CASTER(o)
				return o;
			}
             
			float4 frag( v2f i ) : COLOR {
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
       
		// Pass to render object as a shadow collector
		Pass {
			Name "ShadowCollector"
			Tags { "LightMode" = "ShadowCollector" }
           
			Fog {Mode Off}
			ZWrite On ZTest LEqual
     
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile_shadowcollector
             
			#define SHADOW_COLLECTOR_PASS
			#include "UnityCG.cginc"
 
			float4 _QOffset;
			float _Dist;
 
			struct appdata {
				float4 vertex : POSITION;
			};
             
			struct v2f {
				V2F_SHADOW_COLLECTOR;
			};
             
			v2f vert (appdata v) {
				float4 vPos = mul (UNITY_MATRIX_MV, v.vertex);
				float zOff = vPos.z/_Dist;
				vPos += _QOffset*zOff*zOff;
				v.vertex = mul (vPos, UNITY_MATRIX_IT_MV);
				v2f o;
				TRANSFER_SHADOW_COLLECTOR(o)
				return o;
			}
             
			fixed4 frag (v2f i) : COLOR {
				SHADOW_COLLECTOR_FRAGMENT(i)
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
