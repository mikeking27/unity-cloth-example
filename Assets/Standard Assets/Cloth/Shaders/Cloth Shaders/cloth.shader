Shader "cloth"
{
	Properties
	{
		_velRead ("velRead" , 2D) = "" {}
		_velWrite ("velWrite" , 2D) = "" {}
		_posRead ("posRead" , 2D) = "" {}
		_posWrite ("posWrite" , 2D) = "" {}
		_normals ("normals" , 2D) = "" {}
		_springs ("springs" , 2D) = "" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			//#include "cloth.cginc"
			
			//Definitions used in cloth.shader
			sampler2D _velRead;
			sampler2D _velWrite;
			sampler2D _posRead;
			sampler2D _posWrite;
			sampler2D _normals;
			sampler2D _springs;
			
			struct v2f
			{
				float4 pos : POSITION;
				float2 uv  : TEXCOORD0;
			};
			
			uniform float mass = 1.f;
			uniform float accel = -9.8f;
			uniform float delta = 0.1f;
	
			float3 computeForce(float3 pij , float2 uvSpringEnd , float natLenght , float stiffness)
			{
				float3 pkl = tex2D(_springs , uvSpringEnd);
				float3 diff = pkl - pij;
				return stiffness*(diff - natLenght*(normalize(diff)));
			}
			
			float3 computeInternalForces(float2 curr , float3 v , float3 p)
			{
				float3 ff = float3(0.0,0.0,0.0); 
				curr *= 0.25; 
				for (float x=0.0f ; x < 1.0f ; x+=0.25f)  
				{
					for (float y=0.0f ; y < 1.0f ; y += 0.25f){ 
	  					float4 con = tex2D(_springs, curr);
	  					if (con.r < -0.5) break; 
	  					ff += computeForce(p , con.rg , con.b , con.a); 
					}
				}
				
				return ff;
			}
	
			v2f vert (v2f IN)
			{
				v2f toFrag = IN;
				return toFrag;
			}
			
			float4 frag (v2f fromVert) : COLOR
			{
				float3 v = tex2D(_velRead, fromVert.uv).rgb;  
				float3 p = tex2D(_posRead, fromVert.uv).rgb;
				
				float3 force = computeInternalForces(fromVert.uv , v , p);
				force += mass*accel;
				float3 velOut = v + delta*accel;
				
				return float4(velOut , 1);
			}
			ENDCG
		}
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			//#include "cloth.cginc"
			
			//Definitions used in cloth.shader
			sampler2D _velRead;
			sampler2D _velWrite;
			sampler2D _posRead;
			sampler2D _posWrite;
			sampler2D _normals;
			sampler2D _springs;
			
			struct v2f
			{
				float4 pos : POSITION;
				float2 uv  : TEXCOORD0;
			};
			
			uniform float mass = 1.f;
			uniform float accel = -9.8f;
			uniform float delta = 0.1f;
			
			v2f vert (v2f IN)
			{
				v2f toFrag = IN;
				return toFrag;
			}
			
			float4 frag (v2f fromVert) : COLOR
			{
				float3 p = tex2D(_posRead , fromVert.uv);
				float3 v = tex2D(_velRead , fromVert.uv);
				float3 posOut = p + v*delta + accel*delta*delta*0.5;
				return float4(posOut , 1);
			}
			ENDCG
		}
		
		
	} 
	FallBack "Diffuse"
}
