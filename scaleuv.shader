Shader "BeGrid/ScaleUV"
{
    Properties
    {
		_GridTexture("Grid Texture", 2D) = "white" {}
        _GridColor("Grid Color", Color) = (1, 1, 1, 1)
		_SecondColor("Secondary Color", Color) = (1, 1, 1, 1)
		_Thirdcolor("Tertiary Color", Color) = (1, 1, 1, 1)
		_Blend("Grid Blend", Range(0, 0.5)) = 0.25
		_GridScale ("Grid Scale", Float) = 1
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { 			
            "Queue"="Geometry"
			"IgnoreProjector"="False"
			"RenderType"="Opaque" 
        }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _GridTexture;
        half _GridScale;
        fixed4 _GridColor;
		fixed4 _SecondColor;
		fixed4 _Thirdcolor;
        half _Smoothness;
		half _Blend;

        struct Input
        {
            // float4 pos : SV_POSITION;
            float4 vertex : POSITION;
            float2 uv_GridTexture : TEXCOORD0;
            float3 normal : NORMAL;
            half4 color : COLOR;
        };

        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input, o);

       }

        half3 ObjectScale() {
            return half4(
                length(unity_ObjectToWorld._m00_m10_m20),
                length(unity_ObjectToWorld._m01_m11_m21),
                length(unity_ObjectToWorld._m02_m12_m22),
                1);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            half3 objScale = ObjectScale();

            // go per axis?
            IN.uv_GridTexture *= ObjectScale().xy * _GridScale;
            half3 finalGrid = tex2D(_GridTexture, IN.uv_GridTexture);

            half3 gridColors = _GridColor * clamp(finalGrid.b, _Blend, 1);

			// paint white dots (finalGrid.g is mask)
			half invertDots = 1-finalGrid.g;
			half3 c = finalGrid.g * _SecondColor;
			// screen blend mode
			c = 1 - (1-c) * (1-gridColors);

			// paint red corners
			half3 corners = finalGrid.r * _Thirdcolor;
			c = 1 - (1-corners) * (1 - c);

			// Smoothness
			half3 s = finalGrid.b;

			o.Albedo = c;
            o.Emission = c * 0.75;
            // o.Emission = c;
			o.Alpha = 1;

            // Roughness
            o.Smoothness = s * _Smoothness;
            
        }

        ENDCG
    }
    FallBack "Diffuse"
}
