using System;
using System.Collections;
using UnityEngine;
using UnityEngine.VFX;

public class StateSituation : MonoBehaviour
{
    [Header("Materiales del piso")]
    [SerializeField] private Material[] materialesPiso;
    [SerializeField] private Renderer pisoRenderer;

    [Header("Fuegos (VFX)")]
    [SerializeField] private VisualEffect[] fires;
    [SerializeField] private string vfxColorProperty = "Color"; // <-- nombre del parámetro en tu VFX

    [Header("Tiempo y colores")]
    [SerializeField] private float time = 1f;
    [SerializeField] private Color[] colors;

    private bool isRunning = false;

    private void Start()
    {
        // Iniciar la secuencia
        StartCoroutine(SequenceMaterials());
    }

    private IEnumerator SequenceMaterials()
    {
        isRunning = true;

        for (int i = 0; i < materialesPiso.Length; i++)
        {
            // Cambiar material del piso
            pisoRenderer.material = materialesPiso[i];

            // Cambiar color de los fuegos
            Color colorToUse = colors[i % colors.Length];

            foreach (var fire in fires)
            {
                fire.SetVector4(vfxColorProperty, colorToUse);
            }

            yield return new WaitForSeconds(time);
        }

        // Repetir ciclo
        StartCoroutine(SequenceMaterials());
    }
}

