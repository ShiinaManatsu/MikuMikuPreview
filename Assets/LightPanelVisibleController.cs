using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightPanelVisibleController : MonoBehaviour
{
    public delegate void SetTransparent();

    private CanvasGroup CanvasGroup { get; set; }

    // animate the game object from -1 to +1 and back
    public float minimum = 0.2F;
    public float maximum = 1.0F;

    public float fadeSpeed = 1f;

    // starting value for the Lerp
    static float t = 0.0f;

    SetTransparent handler;
    private void FixedUpdate()
    {
        //InvokeHandler();
        handler?.Invoke();
    }

    private void InvokeHandler()
    {
        foreach (var item in handler.GetInvocationList())
        {
            item?.DynamicInvoke();
        }
    }

    private void Start()
    {
        CanvasGroup = GetComponent<CanvasGroup>();
    }

    public void MouseEnter()
    {
        handler += Appear;
        handler -= Disappear;
    }

    public void MouseExit()
    {
        handler += Disappear;
        handler -= Appear;
    }

    private void Appear()
    {
        CanvasGroup.alpha = Mathf.Lerp(minimum, maximum, Mathf.SmoothStep(0.0f, 1.0f, Mathf.SmoothStep(0.0f, 1.0f, t)));

        // .. and increase the t interpolater
        t += fadeSpeed * Time.deltaTime;

        // now check if the interpolator has reached 1.0
        // and swap maximum and minimum so game object moves
        // in the opposite direction.
        if (t > 1.0f)
        {
            handler -= Appear;
        }
    }
    private void Disappear()
    {
        CanvasGroup.alpha = Mathf.Lerp(minimum, maximum, Mathf.SmoothStep(0.0f, 1.0f, Mathf.SmoothStep(0.0f, 1.0f, t)));

        // .. and increase the t interpolater
        t -= fadeSpeed * Time.deltaTime;

        // now check if the interpolator has reached 0
        // and swap maximum and minimum so game object moves
        // in the opposite direction.
        if (t < 0f)
        {
            t = 0.0f;
            handler -= Disappear;
        }
    }
}
