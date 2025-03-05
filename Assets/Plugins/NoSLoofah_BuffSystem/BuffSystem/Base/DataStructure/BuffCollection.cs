using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace NoSLoofah.BuffSystem
{
    /// <summary>
    /// ��������Buff��ScriptableObject��
    /// </summary>
    [CreateAssetMenu(fileName = "BFcollection", menuName = "BFcollection")]
    public class BuffCollection : ScriptableObject
    {
        [SerializeField] private int size = 20;
        [HideInInspector] public List<Buff> buffList = new List<Buff>();
        public int Size => size;
        /// <summary>
        /// �޸����Buff����
        /// </summary>
        /// <param name="size">Ŀ������</param>
        public void Resize(int size)
        {
            while (size < buffList.Count) buffList.RemoveAt(buffList.Count - 1);
            while (size > buffList.Count) buffList.Add(Buff.CreateInstance("PlaceholderBuff", buffList.Count));
            this.size = size;
        }
        /// <summary>
        /// �������Buff�����������ڶ���ʱ��ʼ��
        /// </summary>
        public void Resize()
        {
            Resize(size);
        }
    }
}