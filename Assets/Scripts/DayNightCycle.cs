using UnityEngine;

public class DayNightCycle : MonoBehaviour
{
    [Header("Configuración del Ciclo")]
    [Tooltip("Duración de un día completo en segundos")]
    [SerializeField] private float duracionDia = 120f; // 2 minutos por defecto

    [Tooltip("Hora inicial del día (0-24)")]
    [SerializeField] private float horaInicial = 12f;

    [Header("Rotación")]
    [Tooltip("Velocidad de rotación del sol")]
    private float velocidadRotacion;

    [Header("Colores del Día")]
    [SerializeField] private Gradient colorLuz;
    [SerializeField] private bool usarGradienteColor = true;

    [Header("Intensidad")]
    [SerializeField] private AnimationCurve curvaIntensidad;
    [SerializeField] private float intensidadMaxima = 1f;

    // Variables privadas
    public Light luzDireccional;
    private float tiempoActual;

    void Start()
    {
        // Obtener el componente Light

        if (luzDireccional == null)
        {
            Debug.LogError("No se encontró un componente Light en este GameObject!");
            enabled = false;
            return;
        }

        // Calcular velocidad de rotación (360 grados / duración en segundos)
        velocidadRotacion = 360f / duracionDia;

        // Configurar tiempo inicial
        tiempoActual = horaInicial / 24f;

        // Inicializar gradiente y curva si no están configurados
        InicializarGradienteDefault();
        InicializarCurvaDefault();

        // Aplicar rotación inicial
        ActualizarRotacion();
    }

    void Update()
    {
        // Actualizar el tiempo (0 a 1 representa un día completo)
        tiempoActual += (Time.deltaTime / duracionDia);

        // Reiniciar el ciclo cuando se complete
        if (tiempoActual >= 1f)
        {
            tiempoActual = 0f;
        }

        // Actualizar la rotación de la luz
        ActualizarRotacion();

        // Actualizar color si está habilitado
        if (usarGradienteColor && colorLuz != null)
        {
            luzDireccional.color = colorLuz.Evaluate(tiempoActual);
        }

        // Actualizar intensidad
        if (curvaIntensidad != null)
        {
            luzDireccional.intensity = curvaIntensidad.Evaluate(tiempoActual) * intensidadMaxima;
        }
    }

    private void ActualizarRotacion()
    {
        // Calcular la rotación (el sol sale por el este y se pone por el oeste)
        float angulo = tiempoActual * 360f;
        transform.rotation = Quaternion.Euler(new Vector3((angulo - 90f), 170f, 0));
    }

    private void InicializarGradienteDefault()
    {
        if (colorLuz == null || colorLuz.colorKeys.Length == 0)
        {
            colorLuz = new Gradient();

            // Crear un gradiente con colores del día
            GradientColorKey[] colorKeys = new GradientColorKey[5];
            colorKeys[0] = new GradientColorKey(new Color(0.2f, 0.2f, 0.3f), 0f);      // Medianoche - Azul oscuro
            colorKeys[1] = new GradientColorKey(new Color(1f, 0.6f, 0.3f), 0.23f);      // Amanecer - Naranja
            colorKeys[2] = new GradientColorKey(new Color(1f, 0.95f, 0.8f), 0.5f);      // Mediodía - Blanco cálido
            colorKeys[3] = new GradientColorKey(new Color(1f, 0.5f, 0.2f), 0.73f);      // Atardecer - Naranja rojizo
            colorKeys[4] = new GradientColorKey(new Color(0.2f, 0.2f, 0.3f), 1f);       // Medianoche - Azul oscuro

            GradientAlphaKey[] alphaKeys = new GradientAlphaKey[2];
            alphaKeys[0] = new GradientAlphaKey(1f, 0f);
            alphaKeys[1] = new GradientAlphaKey(1f, 1f);

            colorLuz.SetKeys(colorKeys, alphaKeys);
        }
    }

    private void InicializarCurvaDefault()
    {
        if (curvaIntensidad == null || curvaIntensidad.keys.Length == 0)
        {
            curvaIntensidad = new AnimationCurve();
            curvaIntensidad.AddKey(0f, 0f);      // Medianoche - Sin luz
            curvaIntensidad.AddKey(0.23f, 0.5f);  // Amanecer - Media luz
            curvaIntensidad.AddKey(0.5f, 1f);     // Mediodía - Luz máxima
            curvaIntensidad.AddKey(0.73f, 0.5f);  // Atardecer - Media luz
            curvaIntensidad.AddKey(1f, 0f);       // Medianoche - Sin luz
        }
    }

    // Métodos públicos para control externo
    public void EstablecerHora(float hora)
    {
        tiempoActual = Mathf.Clamp(hora / 24f, 0f, 1f);
        ActualizarRotacion();
    }

    public float ObtenerHoraActual()
    {
        return tiempoActual * 24f;
    }

    public void CambiarVelocidad(float nuevaDuracion)
    {
        duracionDia = Mathf.Max(1f, nuevaDuracion);
        velocidadRotacion = 360f / duracionDia;
    }
}
