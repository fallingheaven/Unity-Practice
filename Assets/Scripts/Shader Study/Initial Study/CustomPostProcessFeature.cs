using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 使用前提是项目不用urp的设置
[ExecuteInEditMode, ImageEffectOpaque]
public class CustomPostProcessFeature : MonoBehaviour
{
    public Material postProcessMaterial;
    
    private void Start()
    {
        Camera cam = GetComponent<Camera>();
        cam.depthTextureMode |= DepthTextureMode.Depth | DepthTextureMode.DepthNormals;
    }
    
    // 应用后处理效果，内置管线使用
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        // Debug.Log(1);
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