using UnityEngine;
using System.Collections;

public class EffectScreenQuad : MonoBehaviour
{
	public Vector2 dimensions;
	public Camera cam;
	
	// Use this for initialization
	void Start ()
	{
        Vector3[] vertices  = new Vector3[4];
        Vector3[] normals   = new Vector3[4];
        Vector2[] uv        = new Vector2[4];
        int[] triangles 	= new int[6];
		
		//Create plane vertices that fill a dimensions.x*dimension.y pixels rect
		Vector3 lowerLeftPlaneScreenPos	= new Vector3(0,0,0);
		Vector3 lowerRightPlaneScreenPos= new Vector3(dimensions.x , 0 , 0);
		Vector3 upperLeftPlaneScreenPos = new Vector3(0 , dimensions.y , 0);
		
		Vector3 lowerLeftPlaneWorldPos  = cam.ScreenToWorldPoint(lowerLeftPlaneScreenPos);
		Vector3 lowerRightPlaneWorldPos = cam.ScreenToWorldPoint(lowerRightPlaneScreenPos);
		Vector3 upperLeftPlaneWorldPos = cam.ScreenToWorldPoint(upperLeftPlaneScreenPos);
		
        vertices[0] = lowerLeftPlaneWorldPos;
        vertices[1] = lowerRightPlaneWorldPos;
        vertices[2] = upperLeftPlaneWorldPos;
        vertices[3] = upperLeftPlaneWorldPos + lowerRightPlaneWorldPos;

        for (int i = 0; i < 4; i++)
            normals[i] = Vector3.back;

        uv[0] = Vector2.zero;
        uv[1] = Vector2.right;
        uv[2] = Vector2.up;
        uv[3] = Vector2.right + Vector2.up;
        
        triangles[0] = 0;
        triangles[1] = 1;
        triangles[2] = 2;
        triangles[3] = 0;
        triangles[4] = 2;
        triangles[5] = 3;

        MeshFilter mesh_filter		= gameObject.GetComponent("MeshFilter") as MeshFilter;
		mesh_filter.mesh = new Mesh ();
        mesh_filter.mesh.vertices 	= vertices;
        mesh_filter.mesh.normals   	= normals;
        mesh_filter.mesh.uv        	= uv;
        mesh_filter.mesh.triangles 	= triangles;
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
