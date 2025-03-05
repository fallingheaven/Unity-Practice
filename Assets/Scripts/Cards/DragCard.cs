using UnityEngine;
using UnityEngine.EventSystems;

public class DragCard : MonoBehaviour, IBeginDragHandler, IDragHandler, IEndDragHandler
{
    public CardManager cardManager;
    private CardPreview _cardPreview;
    private Transform _previousParent;

    private void OnEnable()
    {
        _cardPreview = GetComponent<CardPreview>();
        _previousParent = transform.parent;
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        transform.SetParent(transform.root);
        
        cardManager.dragging = true;
        cardManager.currentCard = gameObject;
        // TODO: 辅助说明显示
    }

    public void OnDrag(PointerEventData eventData)
    {
        transform.localPosition = Input.mousePosition - new Vector3(Screen.width / 2f, Screen.height / 2f);
    }
    
    public void OnEndDrag(PointerEventData eventData)
    {
        cardManager.dragging = false;
        
        if (Input.GetButtonDown("Mouse X") || cardManager.withinRange) return;
        
        Debug.Log("复位");
        transform.SetParent(_previousParent);
        
        _cardPreview.OnDragExit();
    }
    
}
