using UnityEngine;
using System.Collections;

public class EffectCamera : MonoBehaviour {
	public Vector2 dimensions;
	public Camera cam;
	public RenderTexture renderTexture;
	
	// Use this for initialization
	void Start () {
	}
	
	// Update is called once per frame
	void Update () {
	
	}
	
	public void changeRenderTexture(RenderTexture renderTex , Vector2 dim)
	{
		dimensions = dim;
		changeRenderTexture (renderTex);
		cam.orthographicSize = dim.x/2;
	}
	
	public void changeRenderTexture(RenderTexture renderTex)
	{
		renderTexture = renderTex;
		cam.targetTexture = renderTex;
		RenderTexture.active = renderTex;
	}
	
	void OnRenderImage(RenderTexture src , RenderTexture dst)
	{
		Texture2D tex2D = new Texture2D((int)dimensions.x , (int)dimensions.y ,
			TextureFormat.ARGB32 , false);
		tex2D.ReadPixels(new Rect(0 , 0 , dimensions.x , dimensions.y) , 0 , 0);
		Color[] colors = tex2D.GetPixels ();
		int dummy = 0;
	}
}
