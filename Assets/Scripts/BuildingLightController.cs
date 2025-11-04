using System.Collections.Generic;
using UnityEngine;

public class BuildingLightController : MonoBehaviour
{
    [Header("Luz Direccional")]
    public Light luzDireccional;
    public AnimationCurve curvaIntensidad = AnimationCurve.EaseInOut(0, 0, 10, 1);
    public float intensidadMaxima = 1f;
    public float duracionCiclo = 10f;

    [Header("Objetos a controlar")]
    public List<Renderer> renderObjects = new List<Renderer>();

    private List<Material> materiales = new List<Material>();
    private float tiempoActual = 0f;

    void Start()
    {
        // Clonamos materiales para no modificarlos globalmente
        foreach (var obj in renderObjects)
        {
            if (obj != null)
            {
                Material mat = new Material(obj.sharedMaterial);
                obj.material = mat;
                materiales.Add(mat);
            }
        }
    }

    void Update()
    {
        // Control del tiempo
        tiempoActual += Time.deltaTime;
        if (tiempoActual > duracionCiclo)
            tiempoActual = 0;

        // Evaluar intensidad segun la curva
        float intensidad = curvaIntensidad.Evaluate(tiempoActual / duracionCiclo) * intensidadMaxima;

        // Cambiar la luz direccional
        if (luzDireccional != null)
            luzDireccional.intensity = intensidad;

        // Aplicar intensidad a los materiales
        foreach (var mat in materiales)
        {
            if (mat != null)
                mat.SetFloat("_Intensity", Mathf.Clamp01(1 - intensidad));
        }
    }
}
