using UnityEngine;

[CreateAssetMenu(menuName = "Manager/CardManager")]
public class CardManager : ScriptableObject
{
    public bool dragging;
    public bool withinRange;
    // public bool used;
    public GameObject currentCard;
    // public Pair<Vector2, Vector2> useRange;
}
//
// [System.Serializable]
// public struct Pair<T1, T2>
// {
//     public T1 first;
//     public T2 second;
//
//     private Pair(T1 a, T2 b)
//     {
//         first = a;
//         second = b;
//     }
// }