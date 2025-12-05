using UnityEngine;

public class PlayerController : MonoBehaviour
{

    [Header("Movimiento")]
    public float moveSpeed = 5f;

    [Header("Componentes")]
    public Rigidbody rb;
    public Animator animator;
    public Transform cameraTransform;

    private Vector3 moveDirection;

    void Start()
    {
        if (!rb) rb = GetComponent<Rigidbody>();
        rb.freezeRotation = true; // Para que no se caiga de lado

        if (!cameraTransform) cameraTransform = Camera.main.transform;
    }

    void Update()
    {
        // Entrada
        float h = Input.GetAxisRaw("Horizontal");
        float v = Input.GetAxisRaw("Vertical");

        // Dirección basada en la cámara
        Vector3 camF = cameraTransform.forward;
        Vector3 camR = cameraTransform.right;

        camF.y = 0;
        camR.y = 0;

        camF.Normalize();
        camR.Normalize();

        moveDirection = (camF * v + camR * h).normalized;

        // Animación
        float speedPercent = moveDirection.magnitude;
        animator.SetFloat("Speed", speedPercent);

        // Rotación hacia donde caminamos
        if (moveDirection != Vector3.zero)
        {
            Quaternion targetRot = Quaternion.LookRotation(moveDirection);
            transform.rotation = Quaternion.Slerp(transform.rotation, targetRot, 12f * Time.deltaTime);
        }
    }

    void FixedUpdate()
    {
        // Movimiento físico
        rb.MovePosition(rb.position + moveDirection * moveSpeed * Time.fixedDeltaTime);
    }
}
