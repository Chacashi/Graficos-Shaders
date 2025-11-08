using System.Collections.Generic;
using UnityEngine;

public class BuildingLightController : MonoBehaviour
{
    [Header("Referencia al ciclo de día/noche")]
    public DayNightCycle ciclo;

    [Header("Renderers del edificio")]
    [Tooltip("Arrastra aquí los objetos (paredes, ventanas, etc.) que tengan materiales con emisión.")]
    public List<Renderer> renderObjects = new List<Renderer>();

    [Header("Configuración de emisión")]
    [Tooltip("Intensidad de emisión durante la noche (brillo).")]
    public float intensidadNoche = 1.5f;

    [Tooltip("Intensidad de emisión durante el día (apagado = 0).")]
    public float intensidadDia = 0f;

    private List<Material> materiales = new List<Material>();
    private bool lucesEncendidas = false;

    void Start()
    {
        if (ciclo == null)
        {
            Debug.LogWarning($"{name}: No se asignó un DayNightCycle. No podrá actualizar el estado de las luces.");
        }

        materiales.Clear();
        foreach (var rend in renderObjects)
        {
            if (rend == null) continue;

            // Clonar materiales individuales
            Material[] mats = rend.materials;
            for (int i = 0; i < mats.Length; i++)
            {
                mats[i] = new Material(mats[i]); // evita modificar globalmente
            }
            rend.materials = mats;
            materiales.AddRange(mats);
        }
    }

    void Update()
    {
        if (ciclo == null) return;

        bool esDeDia = ciclo.EsDeDia;

        if (esDeDia && lucesEncendidas)
        {
            ApagarEmision();
            lucesEncendidas = false;
        }
        else if (!esDeDia && !lucesEncendidas)
        {
            EncenderEmision();
            lucesEncendidas = true;
        }
    }

    private void EncenderEmision()
    {
        foreach (var mat in materiales)
        {
            if (mat == null) continue;

            // Para tu shader FullMapsURP
            if (mat.HasProperty("_EmissionStrength"))
            {
                mat.SetFloat("_EmissionStrength", intensidadNoche);
            }

            // Si también usas una propiedad de color opcional:
            if (mat.HasProperty("_EmissionColor"))
            {
                mat.SetColor("_EmissionColor", new Color(1f, 0.75f, 0.4f)); // cálido
            }
        }
    }

    private void ApagarEmision()
    {
        foreach (var mat in materiales)
        {
            if (mat == null) continue;

            if (mat.HasProperty("_EmissionStrength"))
            {
                mat.SetFloat("_EmissionStrength", intensidadDia);
            }

            if (mat.HasProperty("_EmissionColor"))
            {
                mat.SetColor("_EmissionColor", Color.black);
            }
        }
    }
}
