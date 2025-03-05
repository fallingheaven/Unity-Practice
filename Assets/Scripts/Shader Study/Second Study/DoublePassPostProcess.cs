using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class DoublePassPostProcess : MonoBehaviour
{
    public Material postprocessMaterial;

    private void Start()
    {
        
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination){
        //draws the pixels from the source texture to the destination texture
        var temporaryTexture = RenderTexture.GetTemporary(source.width, source.height);
        Graphics.Blit(source, temporaryTexture, postprocessMaterial, 0);
        Graphics.Blit(temporaryTexture, destination, postprocessMaterial, 1);
        RenderTexture.ReleaseTemporary(temporaryTexture);
    }
}
