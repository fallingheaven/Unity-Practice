using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;

public class ShineUseRange : MonoBehaviour
{
    public CardManager cardManager;
    public float shineTime;

    [Header("事件")] public GameObjectEventSO cardUseEventSO;

    private bool _shining;
    private Image _image;
    private BoxCollider2D _boxCollider2D;
    private void OnEnable()
    {
        _image = GetComponent<Image>();
        _boxCollider2D = GetComponent<BoxCollider2D>();
    }

    private void FixedUpdate()
    {
        // Debug.Log(_boxCollider2D.bounds);
        // Debug.Log(Input.mousePosition);
        
        if (cardManager.dragging && _boxCollider2D.bounds.Contains(Input.mousePosition))
        {
            // Debug.Log("shine");
            _shining = true;
            cardManager.withinRange = true;
            StartCoroutine(StartShowRange());
        }
        
        if (_shining)
        {
            if (!cardManager.dragging)
            {
                // Debug.Log("使用");
                cardUseEventSO.RaiseEvent(cardManager.currentCard);
                
                _shining = false;
                StartCoroutine(EndShowRange());
            }
            else if (!_boxCollider2D.bounds.Contains(Input.mousePosition))
            {
                // Debug.Log("end shine");
                
                _shining = false;
                cardManager.withinRange = false;
                StartCoroutine(EndShowRange());
            }
        }
    }

    private IEnumerator StartShowRange()
    {
        _image.DOColor(new Color(1, 1, 0.7f, 1), shineTime);
        yield return null;
    }

    private IEnumerator EndShowRange()
    {
        _image.DOColor(new Color(1, 1, 1, 1), shineTime);
        yield return null;
    }
}
