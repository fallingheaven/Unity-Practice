using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace NoSLoofah.BuffSystem.Manager
{
    /// <summary>
    /// Buff�������Ľӿ�
    /// </summary>
    public interface IBuffManager
    {
        /// <summary>
        /// ͨ����Ż��Buff����
        /// </summary>
        /// <param name="id">Buff��id</param>
        /// <returns>��Ӧ��Buff����</returns>
        public IBuff GetBuff(int id);
        /// <summary>
        /// ע��BuffTagManager
        /// </summary>
        /// <param name="mgr">BuffTagManager</param>
        public void RegisterBuffTagManager(IBuffTagManager mgr);
    }
}