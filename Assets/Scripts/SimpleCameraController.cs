using System.Collections;
using UnityEngine;

namespace UnityTemplateProjects
{
    public class SimpleCameraController : MonoBehaviour
    {
        public CanvasGroup canvas;

        public IEnumerator ResetCanvasAlpha(float oldValue, float newValue, float duration)
        {
            for (float t = 0f; t < duration; t += Time.deltaTime)
            {
                canvas.GetComponent<CanvasGroup>().alpha = Mathf.Lerp(oldValue, newValue, t / duration);
                yield return null;
            }
            canvas.GetComponent<CanvasGroup>().alpha = newValue;
        }

        void Update()
        {
            if (Input.GetKey(KeyCode.U))
            {
                StartCoroutine(ResetCanvasAlpha(canvas.alpha, 1, 0.5f));
            }
        }
    }

}