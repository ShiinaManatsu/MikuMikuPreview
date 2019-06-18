using MaterialUI;
using SFB;
using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using UnityTemplateProjects;

public class ButtonMethods : MonoBehaviour
{
    public GameObject inputField;
    public CanvasGroup canvas;
    public Camera camera;

    public GameObject widthInput;
    public GameObject HeightInput;

    private static string Path { get; set; }
    public void SelectFolderButtonClick()
    {
        try
        {
            var path = StandaloneFileBrowser.OpenFolderPanel("Select Folder", "", false);
            inputField.GetComponent<InputField>().text = path[0];
            Path = path[0].Replace('\\', '/');
            PreviewBuilder.PreviewBuilder.WorkLocation = Path;
            GameObject.Find("Preview Builder Main").GetComponent<PreviewBuilder.PreviewBuilder>().SelectButton();
        }
        catch (System.Exception)
        {
            // Make toast?
            Debug.Log("User cancled");
        }
    }

    public void SaveRenderTexture()
    {
        GameObject.Find("Preview Builder Main").GetComponent<PreviewBuilder.PreviewBuilder>().MakePreviewButton();
    }

    public void HideButton()
    {
        StartCoroutine(SetCanvasAlpha(canvas.alpha, 0, 0.5f));
        camera.GetComponent<SimpleCameraController>().enabled = true;
    }

    private IEnumerator SetCanvasAlpha(float oldValue, float newValue, float duration)
    {
        for (float t = 0f; t < duration; t += Time.deltaTime)
        {
            canvas.alpha = Mathf.Lerp(oldValue, newValue, t / duration);
            yield return null;
        }
        canvas.alpha = newValue;
    }

    public void ResetButton()
    {
        widthInput.GetComponent<MaterialInputField>().inputField.text = "1000";
        HeightInput.GetComponent<MaterialInputField>().inputField.text = "2000";

        InputFieldMethods.ResetRT();
    }
}
