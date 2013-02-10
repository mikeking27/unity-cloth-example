using UnityEngine;
using System.Collections;

public class EffectCamera : MonoBehaviour {
	public Vector2 dimensions;
	public Camera cam;
	
	// Use this for initialization
	void Start () {
	}
	
	// Update is called once per frame
	void Update () {
	
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
