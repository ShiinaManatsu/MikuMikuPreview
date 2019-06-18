using MaterialUI;
using System.Collections;
using UnityEngine;

public class UIContainer : MonoBehaviour
{

    public void OnProgressLinearButtonClicked()
    {
        DialogProgress dialog = DialogManager.ShowProgressLinear(UIManager.FilesReadingText, UIManager.LoadingText, MaterialIconHelper.GetIcon(MaterialIconEnum.HOURGLASS_EMPTY));
        StartCoroutine(HideWindowAfterSeconds(dialog, 5.0f));
    }

    private IEnumerator HideWindowAfterSeconds(MaterialDialog dialog, float duration)
    {
        yield return new WaitForSeconds(duration);
        dialog.Hide();
    }

    public DialogProgress ShowDialog()
    {
        return DialogManager.ShowProgressLinear(UIManager.FilesReadingText, UIManager.LoadingText, MaterialIconHelper.GetIcon(MaterialIconEnum.HOURGLASS_EMPTY));
    }

}
