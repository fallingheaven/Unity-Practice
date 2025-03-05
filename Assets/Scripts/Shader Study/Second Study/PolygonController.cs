using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Renderer))]
public class PolygonController : MonoBehaviour 
{
    [SerializeField]
    private Vector2[] corners;

    private Material _mat;

    void Start()
    {
        UpdateMaterial();
    }

    void OnValidate()
    {
        UpdateMaterial();
    }
    
    void UpdateMaterial(){
        
        if(_mat == null)
            _mat = GetComponent<Renderer>().sharedMaterial;

        var vec4Corners = corners
            .Select(point => new Vector4(point.x, point.y, 0, 0))
            .ToArray();
        
        _mat.SetVectorArray("_corners", vec4Corners);
        _mat.SetInt("_cornerCount", corners.Length);
    }
}
