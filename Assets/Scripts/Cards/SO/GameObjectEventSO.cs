using UnityEngine;
using UnityEngine.Events;

[CreateAssetMenu(menuName = "Events/GameObjectEventSO")]
public class GameObjectEventSO : ScriptableObject
{
    public UnityAction<GameObject> onEventRaised;

    public void RaiseEvent(GameObject a)
    {
        onEventRaised?.Invoke(a);
    }
}