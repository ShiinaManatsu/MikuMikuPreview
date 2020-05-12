using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UniRx;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Experimental.Rendering.HDPipeline;
using UnityEngine.Experimental.UIElements;

public class ClearSkyCheckBox : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        var toggle = GetComponent<Toggle>();
        GetComponent<Volume>().profile.TryGet(out VisualEnvironment enviroment);
        Observable.EveryUpdate()
            .Select(_ => toggle.value)
            .DistinctUntilChanged()
            .Subscribe(x => enviroment.active = !x);
    }
}
