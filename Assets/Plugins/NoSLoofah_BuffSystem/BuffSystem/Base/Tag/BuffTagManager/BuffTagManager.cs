using NoSLoofah.BuffSystem;
using NoSLoofah.BuffSystem.Manager;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
/// <summary>
/// BuffTag�������ĳ������
/// Ŀǰֻ��λTag��һ��ʵ��
/// </summary>
public abstract class BuffTagManager : MonoBehaviour, IBuffTagManager
{
    public abstract bool IsTagRemoveOther(BuffTag tag, BuffTag other);
    public abstract bool IsTagCanAddWhenHaveOther(BuffTag tag, BuffTag other);
    protected virtual void Start()
    {
        BuffManager.GetInstance().RegisterBuffTagManager(this);
    }
}
