using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using Sirenix.OdinInspector;

[ExecuteInEditMode]
public class DepthScanPostProcess : MonoBehaviour
{
    public Material postProcessMaterial;

    private float _waveDistance = 0f;

    private Tweener _tweener;
    
    private void Start()
    {
        Camera cam = GetComponent<Camera>();
        cam.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void Update()
    {
        // Debug.Log(_waveDistance);
    }

    // 应用后处理效果，内置管线使用
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        postProcessMaterial.SetFloat("_WaveDistance", _waveDistance);
        
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

    [Button("深度扫描线")]
    public void ScanDepth()
    {
        _waveDistance = 0f;

        if (_tweener != null)
        {
            if (_tweener.IsPlaying())
            {
                _tweener.Kill();
            }
        }
        
        _tweener = DOTween.To(
            () => _waveDistance,
            x => _waveDistance = x,
            0.99f,
            5)
            .SetEase(Ease.Linear);
    }
}
