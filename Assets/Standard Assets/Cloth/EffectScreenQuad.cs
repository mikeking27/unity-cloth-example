using UnityEngine;
using System.Collections;

public class EffectScreenQuad : MonoBehaviour
{
	public Vector2 dimensions;
	public GameObject camObj;
	public RenderTexture springTex;
	public int springSubTexSize;
	public Material springInitMaterial;
	
	void SetupPlane()
	{
		Vector3[] vertices  = new Vector3[4];
        Vector3[] normals   = new Vector3[4];
        Vector2[] uv        = new Vector2[4];
        int[] triangles 	= new int[6];
		
		//Create plane vertices that fill a dimensions.x*dimension.y pixels rect
		Vector3 lowerLeftPlaneScreenPos	= new Vector3(0 , 0 , 0);
		Vector3 lowerRightPlaneScreenPos= new Vector3(dimensions.x , 0 , 0);
		Vector3 upperLeftPlaneScreenPos = new Vector3(0 , dimensions.y , 0);
		
		Camera cam = camObj.camera;
		
		Vector3 lowerLeftPlaneWorldPos  = cam.ScreenToWorldPoint(lowerLeftPlaneScreenPos);
		Vector3 lowerRightPlaneWorldPos = cam.ScreenToWorldPoint(lowerRightPlaneScreenPos);
		Vector3 upperLeftPlaneWorldPos = cam.ScreenToWorldPoint(upperLeftPlaneScreenPos);
		Vector3 heightDelta = (upperLeftPlaneWorldPos - lowerLeftPlaneWorldPos)/2;
		Vector3 widthDelta = (lowerRightPlaneWorldPos - lowerLeftPlaneWorldPos)/2;
		
        vertices[0] = lowerLeftPlaneWorldPos;
        vertices[1] = lowerRightPlaneWorldPos;
        vertices[2] = upperLeftPlaneWorldPos;
        vertices[3] = heightDelta + widthDelta;
		
		Vector3 normal = Vector3.Cross(widthDelta , heightDelta);
		normal.Normalize();
        for (int i = 0; i < 4; i++)
            normals[i] = normal;

        uv[0] = Vector2.zero;
        uv[1] = Vector2.right;
        uv[2] = Vector2.up;
        uv[3] = Vector2.right + Vector2.up;
        
        triangles[0] = 0;
        triangles[1] = 2;
        triangles[2] = 1;
        triangles[3] = 1;
        triangles[4] = 2;
        triangles[5] = 3;

        MeshFilter mesh_filter		= gameObject.GetComponent("MeshFilter") as MeshFilter;
		mesh_filter.mesh = new Mesh ();
        mesh_filter.mesh.vertices 	= vertices;
        mesh_filter.mesh.normals   	= normals;
        mesh_filter.mesh.uv        	= uv;
        mesh_filter.mesh.triangles 	= triangles;
	}
	
	// Use this for initialization
	void Start ()
	{
		//Start position texture. Assuming dimensions and position RenderTexture are set in
		//inspector.
      	SetupPlane();
		Camera cam = camObj.camera;
		cam.Render();
		
		//Start spring connection texture
		springInitMaterial.SetFloat("_posTexSize", dimensions.x);
		springInitMaterial.SetFloat("_subTexSize", springSubTexSize);
		renderer.material = springInitMaterial;
		dimensions.x *= springSubTexSize;
		dimensions.y *= springSubTexSize;
		EffectCamera camScript = camObj.GetComponent("EffectCamera") as EffectCamera;
		camScript.changeRenderTexture(springTex , dimensions);
		SetupPlane();
		cam.Render();
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
