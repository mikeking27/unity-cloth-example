Shader "clothInitPos" {
	Properties {
		_posTexSize("_posTexSize",Float)=16
		_posOffset("_posOffset",Float)=5
	}
	SubShader {
		Tags { "RenderType"="Opaque" }

		Pass
		{
			//First pass initializes position texture. To ensure all vertices being generated, a quad must be
			//drawn that fills _posTexSize*_posTexSize pixels.
			
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
		
			uniform float _posTexSize;
			uniform float _posOffset;
			
			struct v2f {
				float4 pos:POSITION;
				float2 uv:TEXCOORD0;
			};
			
			v2f vert(v2f IN)
			{
				v2f toFrag = IN;
				return toFrag;
			}
			
			float4 frag(v2f fromVert):COLOR
			{
				//Generate a regular grid by scaling uv coords by the number of verts and adding the position
				//offset
				float2 scaledUV = fromVert.uv*_posTexSize*_posOffset;
				//return float4(scaledUV.x , 0.0f , scaledUV.y , 1.0f);  //Grid in the y=0 plane. Alpha unused.
				return float4(fromVert.uv.x , 0.0f , fromVert.uv.y , 1.0f);
				//return float4(1 , 1 , 1 , 1);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
