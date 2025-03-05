using UnityEngine;

[ExecuteInEditMode]
public class NormalPostprocessing : MonoBehaviour {
    //material that's applied when doing postprocessing
    [SerializeField]
    private Material postProcessMaterial;
    private void Start()
    {
        var cam = GetComponent<Camera>();
        cam.depthTextureMode |= DepthTextureMode.Depth | DepthTextureMode.DepthNormals;
    }

    //method which is automatically called by unity after the camera is done rendering
    private void OnRenderImage(RenderTexture src, RenderTexture dest){
        
        var viewToWorld = GetComponent<Camera>().cameraToWorldMatrix;
        postProcessMaterial.SetMatrix("_viewToWorld", viewToWorld);
        
        if (postProcessMaterial != null)
        {
            Graphics.Blit(src, dest, postProcessMaterial);
            Debug.Log(postProcessMaterial);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}