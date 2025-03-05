using UnityEngine;
using UnityEngine.Events;

[CreateAssetMenu(menuName = "Events/IntEventSO")]
public class IntEventSO : ScriptableObject
{
    public UnityAction<int> onEventRaised;

    public void RaiseEvent(int a)
    {
        onEventRaised?.Invoke(a);
    }
}
