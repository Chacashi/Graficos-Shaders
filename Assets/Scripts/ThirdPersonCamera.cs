using UnityEngine;

public class OrbitCamera : MonoBehaviour
{
    public Transform target;
    public float distance = 4f;
    public float sensitivity = 3f;

    [Header("Zoom")]
    public float minDistance = 2f;
    public float maxDistance = 20f;
    public float zoomSpeed = 3f;

    [Header("Rotación Vertical Dinámica")]
    public float minRotY_Close = -60f;
    public float minRotY_Far = -20f;
    public float maxRotY = 50f;

    [Header("Altura Dinámica (Offset Y)")]
    public float height_Close = 5f;
    public float height_Far = 15f;

    public float rotX;
    public float rotY;

    void LateUpdate()
    {
        if (!target) return;

        if (Input.GetMouseButton(1))
        {
            rotX += Input.GetAxis("Mouse X") * sensitivity;
            rotY -= Input.GetAxis("Mouse Y") * sensitivity;

            float t = Mathf.InverseLerp(minDistance, maxDistance, distance);

            float minRotY = Mathf.Lerp(minRotY_Close, minRotY_Far, t);

            rotY = Mathf.Clamp(rotY, minRotY, maxRotY);
        }

        float scroll = Input.GetAxis("Mouse ScrollWheel");
        if (scroll != 0)
        {
            distance -= scroll * zoomSpeed;
            distance = Mathf.Clamp(distance, minDistance, maxDistance);
        }

        float t_height = Mathf.InverseLerp(minDistance, maxDistance, distance);

        float currentHeight = Mathf.Lerp(height_Close, height_Far, t_height);

        Quaternion rotation = Quaternion.Euler(rotY, rotX, 0);
        Vector3 direction = rotation * new Vector3(0, currentHeight, -distance);

        transform.position = target.position + direction;
        transform.LookAt(target);
    }
}