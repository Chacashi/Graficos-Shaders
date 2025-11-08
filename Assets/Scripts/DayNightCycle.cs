using UnityEngine;

public class DayNightCycle : MonoBehaviour
{
    [Header("Configuración del Ciclo")]
    [Tooltip("Duración de un día completo en segundos")]
    [SerializeField] private float duracionDia = 60f;

    [Tooltip("Hora inicial del día (0-24)")]
    [SerializeField] private float horaInicial = 6f;

    [Header("Referencia de luz (Sol)")]
    public Light luzDireccional;

    [Header("Color e intensidad del Sol")]
    [SerializeField] private Gradient colorLuz;
    [SerializeField] private AnimationCurve curvaIntensidad;
    [SerializeField] private float intensidadMaxima = 1f;

    // Valor público entre 0 y 1 (0 = amanecer, 0.5 = atardecer, 1 = medianoche)
    [Range(0f, 1f)] public float timeOfDay;

    // --- Propiedad para saber si es día ---
    public bool EsDeDia => timeOfDay >= 0.25f && timeOfDay <= 0.75f;

    void Start()
    {
        if (luzDireccional == null)
        {
            Debug.LogError("Asigna una luz direccional (el sol) en el inspector.");
            enabled = false;
            return;
        }

        // Configurar hora inicial (0-1)
        timeOfDay = horaInicial / 24f;

        // Gradiente por defecto si no hay
        if (colorLuz == null || colorLuz.colorKeys.Length == 0)
        {
            colorLuz = new Gradient();
            colorLuz.SetKeys(
                new GradientColorKey[]
                {
                    new GradientColorKey(new Color(0.2f, 0.2f, 0.3f), 0f),
                    new GradientColorKey(new Color(1f, 0.6f, 0.3f), 0.25f),
                    new GradientColorKey(new Color(1f, 0.95f, 0.8f), 0.5f),
                    new GradientColorKey(new Color(1f, 0.5f, 0.2f), 0.75f),
                    new GradientColorKey(new Color(0.2f, 0.2f, 0.3f), 1f)
                },
                new GradientAlphaKey[]
                {
                    new GradientAlphaKey(1f, 0f),
                    new GradientAlphaKey(1f, 1f)
                }
            );
        }

        if (curvaIntensidad == null || curvaIntensidad.length == 0)
        {
            curvaIntensidad = new AnimationCurve(
                new Keyframe(0f, 0f),
                new Keyframe(0.25f, 0.8f),
                new Keyframe(0.5f, 1f),
                new Keyframe(0.75f, 0.8f),
                new Keyframe(1f, 0f)
            );
        }
    }

    void Update()
    {
        // Avanza el tiempo
        timeOfDay += Time.deltaTime / duracionDia;
        if (timeOfDay > 1f)
            timeOfDay -= 1f;

        // Actualiza luz
        ActualizarSol();
    }

    private void ActualizarSol()
    {
        float angulo = timeOfDay * 360f;
        transform.rotation = Quaternion.Euler(new Vector3((angulo - 90f), 170f, 0));

        luzDireccional.color = colorLuz.Evaluate(timeOfDay);
        luzDireccional.intensity = curvaIntensidad.Evaluate(timeOfDay) * intensidadMaxima;
    }
}
