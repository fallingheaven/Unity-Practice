using System.Collections;
using DG.Tweening;
using UnityEngine;
using UnityEngine.Serialization;

public class ReverseCard : MonoBehaviour
{
    public enum Direction
    {
        Front, Back
    }
    
    public GameObject frontCard;
    public GameObject backCard;
    public float flapTime;
    private readonly Vector3 _flapRotation = new Vector3(0, 90f, 0);
    [FormerlySerializedAs("_direction")] public Direction direction = Direction.Front;

    private void OnEnable()
    {
        // backCard.transform.localRotation = Quaternion.Euler(_flapRotation);
    }

    public void Reverse()
    {
        if (direction == Direction.Front)
        {
            direction = Direction.Back;
            StartCoroutine(ToBack());
            return;
        }

        if (direction == Direction.Back)
        {
            direction = Direction.Front;
            StartCoroutine(ToFront());
            return;
        }
    }

    private IEnumerator ToBack()
    {
        frontCard.transform.DOKill();
        backCard.transform.DOKill();
        Tween tween = frontCard.transform.DOLocalRotate(_flapRotation, flapTime);
        yield return tween.WaitForCompletion();
        backCard.transform.DOLocalRotate(Vector3.zero, flapTime);
        
        yield return null;
    }

    private IEnumerator ToFront()
    {
        frontCard.transform.DOKill();
        backCard.transform.DOKill();
        Tween tween = backCard.transform.DOLocalRotate(_flapRotation, flapTime);
        yield return tween.WaitForCompletion();
        frontCard.transform.DOLocalRotate(Vector3.zero, flapTime);
        
        yield return null;
    }
}

