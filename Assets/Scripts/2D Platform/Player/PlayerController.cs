using System;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    public InputSystem2DPlatform inputSystem;
    public Vector2 inputDirection;
    
    public float jumpForce;
    public float moveVelocity;

    private Rigidbody2D _rigidbody;

    private void Awake()
    {
        inputSystem = new InputSystem2DPlatform();
        inputSystem.Player.Jump.performed += Jump;
    }
    
    private void Start()
    {
        _rigidbody = GetComponent<Rigidbody2D>();
    }

    private void OnEnable()
    {
        inputSystem.Enable();
    }

    private void OnDisable()
    {
        inputSystem.Disable();
    }

    private void Update()
    {
        inputDirection = inputSystem.Player.Move.ReadValue<Vector2>();
    }

    private void FixedUpdate()
    {
        Move();
    }

    private void Move()
    {
        _rigidbody.velocity = new Vector2(inputDirection.x * moveVelocity, _rigidbody.velocity.y);

        if (transform.localScale.x * inputDirection.x < 0)
        {
            var tmp = transform.localScale;
            tmp.x *= -1;
            transform.localScale = tmp;
        }
    }
    
    private void Jump(InputAction.CallbackContext obj)
    {
        _rigidbody.velocity = new Vector2(_rigidbody.velocity.x, 0f);
        _rigidbody.AddForce(transform.up * jumpForce, ForceMode2D.Impulse);
    }
}
