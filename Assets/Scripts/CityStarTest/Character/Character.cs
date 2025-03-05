using System.Collections.Generic;
using UnityEngine;

namespace CityStarTest.Character
{
    public class Character : MonoBehaviour
    {
        /// <summary>
        /// 角色属性
        /// </summary>
        public CharacterStat characterStat;
        
        /// <summary>
        /// 角色数据
        /// </summary>
        public CharacterInfo CharacterInfo { get; private set; }
        
        /// <summary>
        /// 角色buff
        /// </summary>
        public List<CharacterStatusBase> CharacterStatusList;




        /// <summary>
        /// 角色交互
        /// </summary>
        /// <param name="interactableObj"></param>
        public void Interact(IInteractable interactableObj)
        {
            interactableObj.Interact();
        }

        /// <summary>
        /// 角色移动
        /// </summary>
        /// <param name="moveDirection"></param>
        public void Move(Vector2 moveDirection)
        {
            
        }
        
        
        
        
        
        public int CurrentExp
        {
            get => CharacterInfo.currentExp;
            set => CharacterInfo.currentExp = value;
        }

        public int CurrentLevel
        {
            get => CharacterInfo.currentLevel;
            set => CharacterInfo.currentLevel = value;
        }

        public int BagSizeRow
        {
            get => CharacterInfo.bagSizeRow;
            set => CharacterInfo.bagSizeRow = value;
        }
        
        public int BagSizeCol
        {
            get => CharacterInfo.bagSizeCol;
            set => CharacterInfo.bagSizeCol = value;
        }
        
        public float BagSize
        {
            get => CharacterInfo.bagSizeRow * CharacterInfo.bagSizeCol;
        }
        
        
    }

    public class CharacterInfo
    {
        /// <summary>
        /// 当前经验值
        /// </summary>
        public int currentExp;

        /// <summary>
        /// 当前等级
        /// </summary>
        public int currentLevel;
        
        /// <summary>
        /// 背包横向格子数
        /// </summary>
        public int bagSizeRow;
        /// <summary>
        /// 背包竖向格子数
        /// </summary>
        public int bagSizeCol;
    }

    public class CharacterStat
    {
        /// <summary>
        /// 攻击值
        /// </summary>
        public float attack;
        
        /// <summary>
        /// 防御值
        /// </summary>
        public float defense;

        /// <summary>
        /// 速度值
        /// </summary>
        public float agility;

        /// <summary>
        /// 耐力值
        /// </summary>
        public float stamina;
    }

    /// <summary>
    /// 角色buff基类
    /// </summary>
    public class CharacterStatusBase
    {
        /// <summary>
        /// buff名称
        /// </summary>
        public string statName;

        /// <summary>
        /// buff描述
        /// </summary>
        public string description;

        /// <summary>
        /// 是否持久
        /// </summary>
        public bool isPersistent;
        
        /// <summary>
        /// 持续时间
        /// </summary>
        public float duration;

        /// <summary>
        /// 生效中
        /// </summary>
        public bool IsInEffect
        {
            get => Time.time - refreshTime < duration && refreshTime > 0f;
        }

        /// <summary>
        /// 获得/刷新buff时刻
        /// </summary>
        public float refreshTime;
    }

    public interface IInteractable
    {
        public void Interact();
    }
}