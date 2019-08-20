using MaterialUI;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using UnityEngine;
using UnityEngine.UI;

public class UIManager : MonoBehaviour
{
    public GameObject leftCount;
    public GameObject locationInput;
    public GameObject selectButton;
    public GameObject makeButton;
    public GameObject hideButton;
    public GameObject outputText;
    public GameObject widthInput;
    public GameObject heightInput;

    public static string TipText { get; set; }
    public static string FilesReadingText { get; set; }
    public static string LoadingText { get; set; }

    // TODO Change tip toast text
    void Start()
    {
        switch (Application.systemLanguage)
        {
            case var language when (language == SystemLanguage.Chinese) || (language == SystemLanguage.ChineseSimplified) || (language == SystemLanguage.ChineseTraditional):
                SetToChinese();
                break;
            default:
                SetToEnglish();
                break;
        }
    }

    private void SetToEnglish()
    {
    }

    private void SetToChinese()
    {
        leftCount.GetComponent<Text>().text = "剩余数量";
        locationInput.GetComponent<MaterialInputField>().hintText = "PMX目录";
        selectButton.GetComponent<MaterialButton>().text.text = "选择目录";
        makeButton.GetComponent<MaterialButton>().text.text = "生成预览";
        hideButton.GetComponent<MaterialButton>().text.text = "隐藏界面";
        outputText.GetComponent<Text>().text = "导出分辨率";
        widthInput.GetComponent<MaterialInputField>().hintText = "宽";
        heightInput.GetComponent<MaterialInputField>().hintText = "高";
    }

    /// <summary>
    /// Initial xml
    /// </summary>
    private void Awake()
    {
        switch (Application.systemLanguage)
        {
            case var language when (language == SystemLanguage.Chinese) || (language == SystemLanguage.ChineseSimplified) || (language == SystemLanguage.ChineseTraditional):
                FilesReadingText = @"正在从目录收集文件";
                LoadingText = @"读取中";
                TipText = @"游览模式下按"" U ""显示界面";
                break;
            default:
                LoadingText = @"Loading";
                FilesReadingText = @"Reading files";
                TipText = @"Press ""U"" to show UI";
                break;
        }
    }

    /// <summary>
    /// Read language
    /// </summary>
    /// <param name="languageFile">Xml path</param>
    /// <returns></returns>
    public static LanguageConfiguration CreateLanguage(string languageFile)
    {
        XDocument xdoc = XDocument.Load(languageFile);

        var returnLanguage = new LanguageConfiguration();

        var languageInfo = (from t in xdoc.Elements("Language")
                            select t).FirstOrDefault();

        if (languageInfo != null)
        {
            returnLanguage.Name = languageInfo.Attribute("Name").Value;

            var textElements = (from t in xdoc.Element("Language").Elements("Text")
                                select t).ToList();

            var texts = new Dictionary<string, string>();

            foreach (XElement element in textElements)
            {
                if (!texts.ContainsKey(element.Attribute("Key").Value))
                {
                    texts.Add(element.Attribute("Key").Value, element.Value);
                }
            }

            returnLanguage.Texts = texts;
        }

        return returnLanguage;
    }
}


public class LanguageConfiguration
{
    public string Name { get; set; }

    public Dictionary<string, string> Texts { get; set; }

    private string LeftCount { get; set; }

    private string LocationInput { get; set; }

    private string SelectButton { get; set; }

    private string MakeButton { get; set; }

    private string HideButton { get; set; }

    private string OutputText { get; set; }

    private string WidthInput { get; set; }

    private string HeightInput { get; set; }
}