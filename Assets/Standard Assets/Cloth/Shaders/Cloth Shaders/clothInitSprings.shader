Shader "clothInitSprings" {
	Properties {
		_posTexSize("_posTexSize",Float)=16
		_subTexSize("_subTexSize",Float)=4
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		
		Pass
		{
			//Second pass initializes spring connectivity texture. To ensure all connections are generated,
			//a quad must be drawn that fills _posTexSize*_subTexSizeX_posTexSize*_subTexSize pixels. The
			//connectivity texture is divided into _subTexSizeX_subTexSize subtextures that contain the
			//connectivity data for each mesh vertex. Each pixel returned by the fragment shader is an spring
			//connectivity entry. Each entry is in the form (u,v,x,k), where (u,v) are the uv coords for
			//spring other end (the first end is implicit represented), x is spring natural lenght and k is
			//the stiffnes coeficient. For near border vertices not all connections are used (marked as -1)
			
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			uniform int _posTexSize;
			uniform int _subTexSize;
			uniform int connectionRings = 2;
			uniform float stiffnes = 0.5f;
			uniform float natLenght = 3.0f;
			uniform float epsilon = 1e-10;
			
			struct v2f {
				float4 pos:POSITION;
				float2 uv:TEXCOORD0;
			};
			
			v2f vert(v2f IN)
			{
				v2f toFrag;
				toFrag.pos = mul(UNITY_MATRIX_MVP , IN.pos);
				toFrag.uv = IN.uv;
				return toFrag;
			}
			
			//Actually calculates the spring connection entry. All float parameters are supposed to
			//be scaled to [0,1] range.
			float4 computeSpringConnection(float vertexRow , float vertexCol , float subTextureRow ,
				float subTextureCol , int posTexSize , int _subTexSize , float natLenght ,
				float stiffnes)
			{
				//float conRing = subTextureRow*0.5f;
				
				//if(conRing < 0.5 + epsilon) //Add entry if its associaded vertex ring is allowed
				//{
					//Each vertex ring has 8 vertices max. The code bellow have 4 possibilities for each
					//iSign, giving all 8 possibilities. For conRing k=0 || k = 1, the connection entries
					//are:
					//-------------------------------------
					//|Entries for k-1, if applicable     |
					//-------------------------------------
					//|(i+k,j)|(i+k,j+k)|(i,j+k)|(i-k,j+k)|
					//|(i-k,j)|(i-k,j-k)|(i,j-k)|(i+k,j-k)|
					//-------------------------------------
					//|Entries for k+1, if applicable     |
					//-------------------------------------
					//
					//Values are scaled to [0,1]
					
					//float springEndRow;
					//float springEndCol;
					
					//float iSign = (subTextureRow - conRing*0.5 > 0.25 +- epsilon) ? 1 : -1;
					
					//if(subTextureCol == 0)
					//{
					//	springEndRow = vertexRow + iSign*conRing; 
					//	springEndCol = vertexCol;
					//}
					//else if(subTextureCol == 1)
					//{
					//	springEndRow = vertexRow + iSign*conRing; 
					//	springEndCol = vertexCol + iSign*conRing;
					//}
					//else if(subTextureCol == 2)
					//{
					//	springEndRow = vertexRow; 
					//	springEndCol = vertexCol + iSign*conRing;
					//}
					//else if(subTextureCol == 3)
					//{
					//	springEndRow = vertexRow - iSign*conRing; 
					//	springEndCol = vertexCol + iSign*conRing;
					//}
					
					//if(springEndRow > -1 && springEndRow < posTexSize && springEndCol > -1 &&
					//	springEndCol < posTexSize) //Check for position texture bounds
					//{
					//	return float4((float)springEndRow , (float)springEndCol , natLenght , stiffnes);
					//}
					//else
					//{
					//	return float4(-1.0f , -1.0f , -1.0f , -1.0f);
					//}
				//}
				//else
				//{
					return float4(-1.0f , -1.0f , -1.0f , -1.0f);
				//}
			}
	
			float4 frag(v2f fromVert):COLOR
			{
				int springTexSize = _subTexSize*_posTexSize;
			
				//First, verifies which vertex subtexture the fragment shader is processing
				//(scaled to [0,1] range)
				float invSpringTexSize = 1f/(_subTexSize*_posTexSize);
				float subTexSizeScaled = _subTexSize*invSpringTexSize;
				float vertexINoScale = floor(fromVert.uv.x/subTexSizeScaled);
				float vertexJNoScale = floor(fromVert.uv.y/subTexSizeScaled);
				
				float vertexI = vertexINoScale/_posTexSize; 
				float vertexJ = vertexJNoScale/_posTexSize;
				
				//Second, verifies which entry in the subtexture the fragment shader is processing.
				//Scale is not really necessary in the final result here, since the subtraction is
				//always less than 1f. Nevertheless, it is done to be more generic in latter coding
				float conEntryI = (fromVert.uv.x - vertexINoScale*subTexSizeScaled)/subTexSizeScaled;
				float conEntryJ = (fromVert.uv.y - vertexJNoScale*subTexSizeScaled)/subTexSizeScaled;
				
				//Third, compute the connection entry and return the pixel with data
				return computeSpringConnection(vertexI , vertexJ , conEntryI , conEntryJ , _posTexSize ,
					_subTexSize , natLenght , stiffnes);
				
				//return float4(vertexI , vertexJ , conEntryI , conEntryJ);
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
