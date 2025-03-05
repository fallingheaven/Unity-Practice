using System.Collections;
using DG.Tweening;
using UnityEngine;

public class ReverseCard : MonoBehaviour
{
    private enum Direction
    {
        Front, Back
    }
    
    public GameObject frontCard;
    public GameObject backCard;
    public float flapTime;
    private readonly Vector3 _flapRotation = new Vector3(0, 90f, 0);
    private Direction _direction = Direction.Front;

    private void OnEnable()
    {
        backCard.transform.localRotation = Quaternion.Euler(_flapRotation);
    }

    public void Reverse()
    {
        if (_direction == Direction.Front)
        {
            _direction = Direction.Back;
            StartCoroutine(ToBack());
            return;
        }

        if (_direction == Direction.Back)
        {
            _direction = Direction.Front;
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

