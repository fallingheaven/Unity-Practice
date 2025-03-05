using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;
using DG.Tweening;

public class CardPreview : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    #region 参变量
    
        public float popTime;
        public float popDisplacement;
        public CardManager cardManager;
        
        [SerializeField] private Vector2 _previousPosition;
        
    #endregion

    private void OnEnable()
    {
        _previousPosition = transform.localPosition;
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        if (cardManager.dragging || cardManager.withinRange) return; // 防止误更新previousPosition
        
        // Debug.Log("开始预览");
        transform.DOKill();
        
        _previousPosition = transform.localPosition;

        StartCoroutine(StartPreview());
    }
    
    public void OnPointerExit(PointerEventData eventData)
    {
        if (cardManager.dragging || cardManager.withinRange) return;
        
        // Debug.Log("结束预览");
        transform.DOKill();

        StartCoroutine(EndPreview());
    }

    public void OnDragExit()
    {
        // Debug.Log("结束拖拽");
        transform.DOKill();

        StartCoroutine(EndPreview());
    }

    private IEnumerator StartPreview()
    {
        transform.DOLocalMoveY(_previousPosition.y + popDisplacement, popTime);
        transform.DOScale(2.5f, popTime);
        yield return null;
    }

    private IEnumerator EndPreview()
    {
        transform.DOLocalMove(_previousPosition, popTime);
        transform.DOScale(2f, popTime);
        yield return null;
    }
}
