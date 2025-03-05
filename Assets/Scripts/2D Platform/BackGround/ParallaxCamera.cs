using System;
using UnityEngine;
using UnityEngine.Events;

[ExecuteInEditMode]
public class ParallaxCamera : MonoBehaviour
{
    public UnityAction<float> onCameraTranslate;

    private float oldPosition;

    void Start()
    {
        oldPosition = transform.position.x;
    }

    void Update()
    {
        if (Math.Abs(transform.position.x - oldPosition) > 1e-6)
        {
            if (onCameraTranslate != null)
            {
                var delta = oldPosition - transform.position.x;
                onCameraTranslate?.Invoke(delta);
            }

            oldPosition = transform.position.x;
        }
    }
}