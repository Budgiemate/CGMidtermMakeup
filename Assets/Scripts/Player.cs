using System.Collections;
using UnityEngine;

public class Player : MonoBehaviour
{
    [SerializeField] private Rigidbody _rb;
    [SerializeField] private GameObject punchBlock;
    [SerializeField] private GameObject enemy;
    private bool isPunching = false;

    public float moveSpeed = 5.0f;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        //check for movement
        if (Input.GetKey(KeyCode.W))
        {
            _rb.linearVelocity = Vector3.forward * moveSpeed;
        }
        if (Input.GetKey(KeyCode.S))
        {
            _rb.linearVelocity = Vector3.back * moveSpeed;
        }
        if (Input.GetKey(KeyCode.A))
        {
            _rb.linearVelocity = Vector3.left * moveSpeed;
        }
        if (Input.GetKey(KeyCode.D))
        {
            _rb.linearVelocity = Vector3.right * moveSpeed;
        }
        
        //check for attack
        if (Input.GetKey(KeyCode.Space))
        {
            if (!isPunching)
            {
                StartCoroutine(Attack());
            }
        }

        IEnumerator Attack()
        {
            //spawn punch block
            GameObject punch = Instantiate(punchBlock, transform.position + Vector3.right * 2, transform.rotation);
            float lightNum = enemy.GetComponent<Renderer>().material.GetFloat("_LightMode");
            enemy.GetComponent<Renderer>().material.SetFloat("_LightMode", (lightNum + 1) % 3);
            isPunching = true;
            
            yield return new WaitForSeconds(0.5f);
            
            isPunching = false;
            Destroy(punch);
        }
    }
}
