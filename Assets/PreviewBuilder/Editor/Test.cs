using MMD;
using PreviewBuilder.Xmls;
using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace PreviewBuilder
{
    /// <summary>
    /// Test class for preview builder
    /// </summary>
    public class Test : Editor
    {
        #region PreviewBuilderTest
        [MenuItem("MMM/Pmx2Fbx")]
        public static void Pmx2Fbx()
        {
            foreach (var i in Selection.objects)
            {
                string path = AssetDatabase.GetAssetPath(i.GetInstanceID());
                path = Application.dataPath.Remove(Application.dataPath.Length - 6) + path;
                path = $"\"{path}\"";   // As we run in the cmd we need to surround with ""
                string pmx2fbx = Application.dataPath.Remove(Application.dataPath.Length - 6) + @"Assets/PreviewBuilder/PMX2FBX/pmx2fbx.exe";

                var p2fProcess = new System.Diagnostics.ProcessStartInfo(pmx2fbx, path)
                {
                    WindowStyle = System.Diagnostics.ProcessWindowStyle.Minimized
                };
                System.Diagnostics.Process.Start(p2fProcess);
            }
        }

        [MenuItem("MMM/XML")]
        public static void XMLTest()
        {
            foreach (var i in Selection.objects)
            {
                string path = AssetDatabase.GetAssetPath(i.GetInstanceID());
                path = Application.dataPath.Remove(Application.dataPath.Length - 6) + path;
                var a = MMDModel.GetMMDModel(path);
            }
        }

        [MenuItem("MMM/File Test")]
        public static void FileTest()
        {
            string path = Application.dataPath + "/PreviewBuilder/Temp/";
            var files = Directory.EnumerateFiles(path, "*.*", SearchOption.AllDirectories)
                            .Where(s => s.EndsWith(".pmx") || s.EndsWith(".pmd"));
            foreach (string f in files)
            {
                Debug.Log(f);
            }
        }

        [MenuItem("MMM/LoadModel")]
        public static void Load()
        {
            try
            {
                //Instantiate(Resources.Load(@"D:\Project.Unity\Awsl\Build\Temp\椛暗式锦绣 V1.0.fbx"));
                var str = Path.Combine(Application.streamingAssetsPath, "椛暗式锦绣 V1.0.fbx");
                var fileStream = new FileStream(str, FileMode.Open, FileAccess.Read);



                var myLoadedAssetBundle = AssetBundle.LoadFromMemory(File.ReadAllBytes(str));
                if (myLoadedAssetBundle == null)
                {
                    Debug.Log("Failed to load AssetBundle!");
                    return;
                }

                var prefab = myLoadedAssetBundle.LoadAsset<GameObject>("椛暗式锦绣 V1.0.fbx");
                Instantiate(prefab);

                myLoadedAssetBundle.Unload(false);
            }
            catch (System.Exception e)
            {
                Debug.LogError(e.Message);
            }
        }

        [MenuItem("MMM/LoadModelTemp")]
        [ExecuteInEditMode]
        public static void LoadT()
        {
            CleanAssetDatabase();
            string path = EditorUtility.OpenFilePanel("Overwrite with png", "", "*");
            Debug.Log(path);
            var model_agent = new ModelAgent(path);

            MMD.PMX.PMXFormat pmx_format;
            try
            {
                //PMX読み込みを試みる
                pmx_format = PMXLoaderScript.Import(model_agent.file_path_);
            }
            catch
            {
                //PMXとして読み込めなかったら
                //PMDとして読み込む
                MMD.PMD.PMDFormat pmd_format = PMDLoaderScript.Import(model_agent.file_path_);
                pmx_format = PMXLoaderScript.PMD2PMX(pmd_format);
            }

            var fbxGameObject = MMD.PMXConverter.CreateGameObject(pmx_format, false, MMD.PMXConverter.AnimationType.LegacyAnimation, false, 1f);

            fbxGameObject.transform.SetParent(GameObject.Find("Parent").transform);
            fbxGameObject.transform.localScale = new Vector3(0.085f, 0.085f, 0.085f);
            fbxGameObject.transform.localRotation = new Quaternion(0f, 0f, 0f, 0f);

        }

        [MenuItem("MMM/XmlTest")]
        public static void XmlTest()
        {
            Debug.Log(Application.dataPath);
        }

        [MenuItem("MMM/CleanAssetDatabase")]
        public static void CleanAssetDatabase()
        {
            Resources.UnloadUnusedAssets();
            GC.Collect();
        }
        #endregion
    }
}