using System;
using UniRx;
using UniRx.Triggers;
using UnityEngine;

public class CameraInput : MonoBehaviour
{
    public GameObject camera;
    public CanvasGroup canvas;

    private IObservable<bool> IsUIEnable { get; set; }

    // Start is called before the first frame update
    void Awake()
    {
        IsUIEnable = this.FixedUpdateAsObservable()
            .Select(x => canvas.alpha == 0 ? false : true);

        IsUIEnable.DistinctUntilChanged()
            .Subscribe(x => camera.SetActive(x ? false : true));

#if UNITY_EDITOR

        IsUIEnable.DistinctUntilChanged()
            .Subscribe(x => Debug.Log(x));

#endif
    }

}
