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
			
			struct v2f {
				float4 pos:POSITION;
				float2 uv:TEXCOORD0;
			};
			
			v2f vert(v2f IN)
			{
				v2f toFrag = IN;
				return toFrag;
			}
			
			//Actually calculates the spring connection entry.
			
			float4 computeSpringConnection(int vertexRow , int vertexCol , int subTextureRow ,
				int subTextureCol , int posTexSize , int _subTexSize , float natLenght , float stiffnes)
			{
				int conRing = subTextureRow/2;
				
				if(conRing < connectionRings) //Just add entries for the required number of connection rings
				{
					//Each vertex ring has 8 vertices max. In this code we have 4 possibilities for each
					//iSign, giving all 8 possibilities. For conRing k=[0,1], the connection entries are:
					//-------------------------------------
					//|Entries for k-1                    |
					//-------------------------------------
					//|(i+k,j)|(i+k,j+k)|(i,j+k)|(i-k,j+k)|
					//|(i-k,j)|(i-k,j-k)|(i,j-k)|(i+k,j-k)|
					//-------------------------------------
					
					int springEndRow;
					int springEndCol;
					int iSign = (subTextureRow%2 == 0) ? 1 : -1;
					
					if(subTextureCol == 0)
					{
						springEndRow = vertexRow + iSign*conRing; 
						springEndCol = vertexCol;
					}
					else if(subTextureCol == 1)
					{
						springEndRow = vertexRow + iSign*conRing; 
						springEndCol = vertexCol + iSign*conRing;
					}
					else if(subTextureCol == 2)
					{
						springEndRow = vertexRow; 
						springEndCol = vertexCol + iSign*conRing;
					}
					else if(subTextureCol == 3)
					{
						springEndRow = vertexRow - iSign*conRing; 
						springEndCol = vertexCol + iSign*conRing;
					}
					
					if(springEndRow > -1 && springEndRow < posTexSize && springEndCol > -1 &&
						springEndCol < posTexSize) //Check for position texture bounds
					{
						return float4((float)springEndRow , (float)springEndCol , natLenght , stiffnes);
					}
					else
					{
						return float4(-1.0f , -1.0f , -1.0f , -1.0f);
					}
				}
				else
				{
					return float4(-1.0f , -1.0f , -1.0f , -1.0f);
				}
			}
	
			float4 frag(v2f fromVert):COLOR
			{
				int springTexSize = _subTexSize*_posTexSize;
			
				//First, verifies which vertex subtexture the fragment shader is processing
				int vertexI = floor(fromVert.uv.x*_subTexSize); 
				int vertexJ = floor(fromVert.uv.y*_subTexSize);
				
				//Second, verifies which entry in the subtexture the fragment shader is processing.
				//Redundant computation just be cleaner...
				int conEntryI = int(floor(fromVert.uv.x*_subTexSize*_posTexSize))%_subTexSize; 
				int conEntryJ = int(floor(fromVert.uv.y*_subTexSize*_posTexSize))%_subTexSize;
				
				return computeSpringConnection(vertexI , vertexJ , conEntryI , conEntryJ , _posTexSize ,
					_subTexSize , natLenght , stiffnes);
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
