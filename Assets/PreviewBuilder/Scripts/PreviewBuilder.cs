using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using MaterialExceptionXML;
using MaterialUI;
using MMD;
using MMD.PMX;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

/// <summary>
/// TODO:
/// For parsing models 
/// Load them to the scene
/// Get preview save to the target folder
/// </summary>
namespace PreviewBuilder
{
    [ExecuteInEditMode]
    public class PreviewBuilder : MonoBehaviour
    {
        /// <summary>
        ///     Create pmx from pmx list
        /// </summary>
        private void CreatePmx()
        {
            var model_agent = new ModelAgent(Statement.PmxFiles[Statement.CurrentPmx]);
            PMXFormat pmx_format;
            try
            {
                //PMX読み込みを試みる
                pmx_format = PMXLoaderScript.Import(model_agent.file_path_);
            }
            catch
            {
                //PMXとして読み込めなかったら
                //PMDとして読み込む
                var pmd_format = PMDLoaderScript.Import(model_agent.file_path_);
                pmx_format = PMXLoaderScript.PMD2PMX(pmd_format);
            }

            fbxGameObject = PMXConverter.CreateGameObject(pmx_format, false, PMXConverter.AnimationType.LegacyAnimation,
                false, 1f);
            fbxGameObject.GetComponentsInChildren<SkinnedMeshRenderer>().ToList().ForEach(x =>
            {
                x.shadowCastingMode = ShadowCastingMode.Off;
            });
            fbxGameObject.transform.SetParent(GameObject.Find("Parent").transform);
            fbxGameObject.transform.localScale = new Vector3(0.085f, 0.085f, 0.085f);
            fbxGameObject.transform.localRotation = new Quaternion(0f, 0f, 0f, 0f);
        }

        private IEnumerator TakePhoto(float waitTime)
        {
            yield return new WaitForSeconds(waitTime);

            // Take photo and set can save rt false
            SaveRenderTextureToFile(Statement.PmxFiles[Statement.CurrentPmx] + ".png");

            // Keep last one stay
            if (Statement.CurrentPmx > 0) Destroy(fbxGameObject);

            Resources.UnloadUnusedAssets();
            GC.Collect();

            Statement.IsSaving = false;
            Statement.CanSaveRT = false;
            MoveNext();
        }

        private void Start()
        {
            UIContainer = canvas.GetComponent<UIContainer>();
            InputFieldMethods.RTHeight = 2000;
            InputFieldMethods.RTWidth = 1000;
            rt = new RenderTexture(InputFieldMethods.RTWidth, InputFieldMethods.RTHeight, 0, RenderTextureFormat.ARGB32,
                RenderTextureReadWrite.sRGB)
            {
                name = "rt",
                depth = 0,
                anisoLevel = 0,
                dimension = TextureDimension.Tex2D,
                antiAliasing = 8
            };

            StartCoroutine(ShowTip(UIManager.TipText, 1));
            StartCoroutine(ShowTip(
                $"Max size of texture: {SystemInfo.maxTextureSize.ToString()} * {SystemInfo.maxTextureSize.ToString()}",
                2));

            MaterialExtraConfigurationList =
                MaterialException.CreateMaterialConfiguration(Path.Combine(Directory.GetCurrentDirectory(),
                    "MaterialConfiguration.xml"));
        }

        private void FixedUpdate()
        {
            if (RemainText != null) RemainText.text = Statement.PmxFiles.Count.ToString();

            if (IsReadingPmxs && dialogProgress == null) dialogProgress = UIContainer.ShowDialog();
            if (!IsReadingPmxs)
                if (dialogProgress != null)
                {
                    dialogProgress.Hide();
                    dialogProgress = null;
                }

            // Save rt since we can
            if (Statement.CanSaveRT && !Statement.IsSaving)
            {
                try
                {
                    SnackbarManager.Show("Saving " + Statement.PmxFiles[Statement.CurrentPmx] + ".png");
                }
                catch
                {
                }

                Statement.IsSaving = true;
                StartCoroutine(TakePhoto(1));
            }


            if (Statement.IsWorking)
            {
                inputField.GetComponent<MaterialInputField>().interactable = false;
                selectButton.GetComponent<MaterialButton>().interactable = false;
                makeButton.GetComponent<MaterialButton>().interactable = false;
            }
            else
            {
                inputField.GetComponent<MaterialInputField>().interactable = true;
                selectButton.GetComponent<MaterialButton>().interactable = true;
            }

            if ((!Statement.IsWorking || !Statement.IsPreviewing) && Statement.CanMakePreview)
                makeButton.GetComponent<MaterialButton>().interactable = true;
            else
                makeButton.GetComponent<MaterialButton>().interactable = false;

            if (Statement.CanMakePreview && !Statement.IsSaving && Statement.IsWorking)
            {
                try
                {
                    CreatePmx();
                }
                catch
                {
                    ToastManager.Show(
                        $"Create {Path.GetFileNameWithoutExtension(Statement.PmxFiles[Statement.CurrentPmx])} Faild, make sure pmx is correct");
                    MoveNext();
                }

                // Take photo~ Update save rt statement
                Statement.CanSaveRT = true;
            }
        }

        private void MoveNext()
        {
            Statement.CurrentPmx--;
            RemainText.text = Statement.PmxFiles.Count.ToString();
            if (Statement.CurrentPmx < 0)
            {
                //Statement.CanMakePreview = false;   // Finished make and reset statement
                Statement.CurrentPmx = 0;
                Statement.PmxFiles.Clear();
                Statement.IsWorking = false;
                ToastManager.Show("Finished");
                Statement.IsPreviewing = true;

                // Finish take photo and release rt
                rtCamera.targetTexture.Release();
                rtCamera.targetTexture = null;
            }
        }

        #region Private Members

        public static RenderTexture rt;
        public static UIContainer UIContainer { get; set; }

        private static bool Flag { get; set; } = false;
        private static volatile bool IsReadingPmxs;
        private DialogProgress dialogProgress;

        private static Statement Statement = new Statement
        {
            CanSaveRT = false,
            IsSaving = false,
            CurrentPmx = 0,
            PmxFiles = new List<string>(),
            CanMakePreview = false,
            IsWorking = false,
            IsPreviewing = true
        };

        private static GameObject fbxGameObject;

        #endregion

        #region Public Members

        /// <summary>
        ///     Located to the specific models
        /// </summary>
        public static string WorkLocation { get; set; }

        public GameObject parent;
        public Text RemainText;
        public GameObject inputField;
        public GameObject selectButton;
        public GameObject makeButton;
        public Camera rtCamera;
        public GameObject canvas;

        public MaterialExtraConfigurationList MaterialExtraConfigurationList { get; set; }

        public bool IsFolderCorrect
        {
            set => Statement.CanMakePreview = value;
        }

        #endregion

        #region Helper Methods

        public void SelectButton()
        {
            FillPmxList();
            Statement.CanMakePreview = true;
        }

        public void MakePreviewButton()
        {
            Statement.IsWorking = true;
            Statement.IsPreviewing = false;
            if (parent.transform.childCount != 0)
            {
                Destroy(fbxGameObject);
                fbxGameObject = null;
                FillPmxList();
            }

            rt = null;
            rt = new RenderTexture(InputFieldMethods.RTWidth, InputFieldMethods.RTHeight, 0, RenderTextureFormat.ARGB32,
                RenderTextureReadWrite.sRGB)
            {
                name = "rt",
                depth = 0,
                anisoLevel = 0,
                dimension = TextureDimension.Tex2D,
                antiAliasing = 8
            };
            rtCamera.targetTexture = rt;
        }


        /// <summary>
        ///     Get all pmx and pmd files
        /// </summary>
        /// <remarks>Return the path of files</remarks>
        /// <param name="sourceDirectory">Source directory</param>
        /// <returns>Return an IEnumerable of files</returns>
        public IEnumerable<string> GetPMXs(string sourceDirectory)
        {
            try
            {
                var path = sourceDirectory;


                var files = Directory.EnumerateFiles(path, "*.*", SearchOption.AllDirectories)
                    .Where(s => Path.GetExtension(s) == ".pmx" || Path.GetExtension(s) == ".pmx");

                return files;
            }
            catch (Exception e)
            {
                ToastManager.Show(e.Message);
                return null;
            }
        }

        public async void FillPmxList()
        {
            await Task.Run(() =>
            {
                try
                {
                    IsReadingPmxs = true;
                    var path = WorkLocation;

                    var files = Directory.EnumerateFiles(path, "*.*", SearchOption.AllDirectories)
                        .Where(s => Path.GetExtension(s).ToUpper() == ".PMX" ||
                                    Path.GetExtension(s).ToUpper() == ".PMD").ToList();

                    files.ForEach(s => { Debug.Log(s); });

                    Statement.PmxFiles = files;
                    Statement.PmxFiles.Reverse();
                    Statement.CurrentPmx = Statement.PmxFiles.Count - 1;
                    IsReadingPmxs = false;
                }
                catch (Exception e)
                {
                    ToastManager.Show(e.Message);
                }
            });
        }

        /// <summary>
        ///     Save render texture to png
        /// </summary>
        /// <param name="filePath">The path to save</param>
        private void SaveRenderTextureToFile(string filePath)
        {
            RenderTexture.active = rt;
            //var rt = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.sRGB);


            var tex = new Texture2D(rt.width, rt.height, TextureFormat.RGBA32, false, true);

            tex.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
            tex.Apply();

            RenderTexture.active = null;

            byte[] bytes;
            bytes = tex.EncodeToPNG();

            File.WriteAllBytes(filePath, bytes);
        }

        private IEnumerator ShowTip(string tip, float waitTime)
        {
            yield return new WaitForSeconds(waitTime);
            ToastManager.Show(tip);
        }

        #endregion
    }

    /// <summary>
    ///     Represents a stament struct of current workflow
    /// </summary>
    internal struct Statement
    {
        public List<string> PmxFiles { get; set; }

        public bool CanSaveRT { get; set; }

        public int CurrentPmx { get; set; }

        public bool IsSaving { get; set; }

        public bool CanMakePreview { get; set; }

        public bool IsWorking { get; set; }

        public bool IsPreviewing { get; set; }
    }
}