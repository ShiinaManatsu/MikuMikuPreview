using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UniRx;
using UniRx.Triggers;
using MaterialUI;

public class RxUIPresenter : MonoBehaviour
{
    public MaterialNavDrawer MaterialNavDrawer;
    public Button MenuButton;

    // Start is called before the first frame update
    void Start()
    {
        MenuButton.OnClickAsObservable().Subscribe(_ =>
        {
            MaterialNavDrawer.Open();
        });
    }
}
