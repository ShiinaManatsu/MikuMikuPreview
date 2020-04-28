using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UniRx;
using UniRx.Triggers;

[ExecuteInEditMode]
public class RT : MonoBehaviour
{
    [Range(0,1)]
    /// <summary>
    /// Percentage for the renderer
    /// </summary>
    public float percentage = 1f;

    public void FixedUpdate()
    {
        var renderer = GetComponent<CanvasRenderer>();
        renderer.SetAlpha(percentage);
    }
}
