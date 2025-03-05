using System;
using Cysharp.Threading.Tasks;
using Cysharp.Threading.Tasks.Triggers;
using UnityEngine;

public class Item : MonoBehaviour, IAsyncOnMouseEnterHandler, IAsyncOnMouseDragHandler, IAsyncOnMouseExitHandler
{
    public async UniTask OnMouseEnterAsync()
    {
        
        await UniTask.Yield();
    }
    
    public async UniTask OnMouseDragAsync()
    {
        transform.position = Input.mousePosition;
        await UniTask.Yield();
    }


    public async UniTask OnMouseExitAsync()
    {
        
        await UniTask.Yield();
    }
}

public struct ItemProperty
{
    public Tuple<int, int> pos;
    
    // 其他属性
}