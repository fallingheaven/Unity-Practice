using System;
using System.Diagnostics;
using UnityEngine;

[DebuggerDisplay("{playerLayer}, {oneWayLayer}")]
public class DropDown : MonoBehaviour
{
    public string playerLayer = "Player";
    public string oneWayLayer = "OneWayPlatform";
    private PlayerController _playerController;

    [DebuggerHidden]
    private void Awake()
    {
        _playerController = GetComponent<PlayerController>();
    }

    private void Update()
    {
        Physics2D.IgnoreLayerCollision(LayerMask.NameToLayer(playerLayer), LayerMask.NameToLayer(oneWayLayer), 
            _playerController.inputDirection.y < 0);
    }
}
