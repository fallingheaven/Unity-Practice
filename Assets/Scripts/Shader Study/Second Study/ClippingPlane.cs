using UnityEngine;

[ExecuteAlways]
public class ClippingPlane : MonoBehaviour {
    //material we pass the values to
    public Material mat;

    //execute every frame
    void Update () {
        //create plane
        var position = transform.position;
        Plane plane = new Plane(transform.up, position);
        //transfer values from plane to vector4
        Vector4 planeNormal = new Vector4(plane.normal.x, plane.normal.y, plane.normal.z, 0);
        Vector4 planePosition = new Vector4(position.x, position.y, position.z, 0);
        //pass vector to shader
        mat.SetVector("_PlaneNormal", planeNormal);
        mat.SetVector("_PlanePosition", planePosition);
    }
}