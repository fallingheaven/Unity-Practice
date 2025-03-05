using UnityEngine;
using UnityEngine.Events;

[CreateAssetMenu(menuName = "Events/IntIntEventSO")]
public class IntIntEventSO : ScriptableObject
{
    public UnityAction<int, int> onEventRaised;

    public void RaiseEvent(int a, int b)
    {
        onEventRaised?.Invoke(a, b);
    }
}