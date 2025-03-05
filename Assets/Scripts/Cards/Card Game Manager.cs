using System.Collections;
using DG.Tweening;
using UnityEngine;

public class CardGameManager : MonoBehaviour
{
    private Matrix4x4 _compare = new(
        new Vector4(0, 1, -1, 0),
        new Vector4(-1, 0, 1, 0),
        new Vector4(1, -1, 0, 0),
        new Vector4(0, 0, 0, 0));

    [Header("事件监听")] public GameObjectEventSO cardUseEventSO;

    public GameObject[] cards;
    public float flapTime;
    public float moveTime;
    public CardManager cardManager;
    public Vector3 playerComparePosition;
    public Vector3 computerComparePosition;

    private void OnEnable()
    {
        cardUseEventSO.onEventRaised += onCardUsed;
    }

    private void OnDisable()
    {
        cardUseEventSO.onEventRaised -= onCardUsed;
    }

    private void onCardUsed(GameObject currentCard)
    {
        if (currentCard == null)
        {
            Debug.Log("没把卡片传进来");
            return;
        }

        currentCard.transform.localScale = Vector3.one * 2;
        // cardManager.used = true;
        
        var computerCard = Instantiate(cards[Random.Range(0, cards.Length - 1)], transform);
        StartCoroutine(StartCompare(currentCard, computerCard));
    }

    private IEnumerator StartCompare(GameObject a, GameObject b)
    {
        a.transform.DOKill();
        
        a.transform.DOLocalMove(playerComparePosition, moveTime);
        b.transform.position = computerComparePosition + new Vector3(Screen.width / 2f, Screen.height / 2f, 0);
        
        a.GetComponent<ReverseCard>().Reverse();
        b.GetComponent<ReverseCard>().Reverse();
        
        // b.transform.DOLocalMove(computerComparePosition, moveTime);
        // a.transform.position = playerComparePosition;

        yield return new WaitForSeconds(1f);
        
        a.GetComponent<ReverseCard>().Reverse();
        b.GetComponent<ReverseCard>().Reverse();

        yield return new WaitForSeconds(flapTime);

        
        switch (_compare[(int)a.GetComponent<Card>().cardKind, (int)b.GetComponent<Card>().cardKind])
        {
            case 0:
                Debug.Log("平局");
                break;
            case 1:
                Debug.Log("玩家胜利");
                break;
            case 2:
                Debug.Log("玩家失败");
                break;
        }
        
        
        yield return new WaitForSeconds(1f);
        
        a.GetComponent<CardPreview>().OnDragExit();
        Destroy(b.gameObject);

        yield return new WaitForSeconds(0.1f);
        cardManager.withinRange = false;
    }
}
