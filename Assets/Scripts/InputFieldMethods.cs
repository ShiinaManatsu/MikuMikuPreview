using MaterialUI;
using System.IO;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Experimental.Rendering.HDPipeline;
using UnityEngine.Rendering;
using UnityEngine.UI;

public class InputFieldMethods : MonoBehaviour
{
    private static int rTWidth = 1000;
    private static int rTHeight = 2000;
    //public GameObject button;
    //public GameObject inputText;
    public GameObject lightTarget;
    private static ProceduralSky proceduralSky;
    private static Light[] light;

    private void Start()
    {
        light = lightTarget.GetComponentsInChildren<Light>();

        GameObject.Find("Volume Settings").GetComponent<Volume>().profile.TryGet(out proceduralSky);
    }

    public static int RTWidth
    {
        get
        {
            return (rTWidth < 100) ? 1000 : rTWidth;
        }
        set
        {
            rTWidth = value;
        }
    }
    public static int RTHeight
    {
        get
        {
            return (rTHeight < 100) ? 2000 : rTHeight;
        }
        set
        {
            rTHeight = value;
        }
    }


    public void FieldChanged()
    {
        if (Directory.Exists(GetComponent<InputField>().text))
        {
            GameObject.Find("Preview Builder Main").GetComponent<PreviewBuilder.PreviewBuilder>().IsFolderCorrect = true;
            GameObject.Find("Preview Builder Main").GetComponent<PreviewBuilder.PreviewBuilder>().FillPmxList();
        }
        else
        {
            GameObject.Find("Preview Builder Main").GetComponent<PreviewBuilder.PreviewBuilder>().IsFolderCorrect = false;
        }
    }

    public void SliderValueChanged()
    {
        for(int i = 0; i < light.Length; i++)
        {
            light[i].intensity = GetComponent<Slider>().value;
        }
    }

    public void SkySliderValueChanged()
    {
        if (proceduralSky != null) { proceduralSky.atmosphereThickness.value = GetComponent<Slider>().value; }
    }

    public void WidthInput()
    {
        try
        {
            RTWidth = int.Parse(GetComponent<MaterialInputField>().inputField.text);
        }
        catch
        {
            ToastManager.Show("Input Not Correct");
        }
    }
    public void HeightInput()
    {
        try
        {
            RTHeight = int.Parse(GetComponent<MaterialInputField>().inputField.text);
        }
        catch
        {
            ToastManager.Show("Input Not Correct");
        }
    }


    public static void ResetRT()
    {
        RTWidth = 1000;
        RTHeight = 2000;
    }
}
