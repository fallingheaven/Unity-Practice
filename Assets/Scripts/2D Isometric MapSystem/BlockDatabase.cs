using UnityEngine;
using System.Collections.Generic;
using System.Linq;

[CreateAssetMenu(fileName = "BlockDatabase", menuName = "Isometric Voxel System/Block Database", order = 1)]
public class BlockDatabase : ScriptableObject
{
    [System.Serializable]
    public struct BlockPrefabMapping
    {
        public BlockType type;
        public GameObject prefab;
    }

    public List<BlockPrefabMapping> blockMappings = new List<BlockPrefabMapping>();

    private Dictionary<BlockType, GameObject> _database = null;

    // 初始化数据库以便快速查找
    private void OnEnable()
    {
        _database = new Dictionary<BlockType, GameObject>();
        foreach (var mapping in blockMappings)
        {
            if (mapping.prefab != null && !_database.ContainsKey(mapping.type))
            {
                // 验证预制件是否包含Block脚本
                if (mapping.prefab.GetComponent<Block>() == null)
                {
                    Debug.LogWarning($"BlockDatabase: Prefab for {mapping.type} is missing the Block component!");
                }
                else if (mapping.prefab.GetComponent<Block>().type != mapping.type)
                {
                    // 确保预制件上的Block脚本类型与数据库设置一致
                     Debug.LogWarning($"BlockDatabase: Prefab for {mapping.type} has mismatched BlockType ({mapping.prefab.GetComponent<Block>().type}) in its Block component. Ensure they match.");
                }
                _database.Add(mapping.type, mapping.prefab);
            }
            else if (_database.ContainsKey(mapping.type))
            {
                 Debug.LogWarning($"BlockDatabase: Duplicate BlockType entry found for {mapping.type}. Using the first one.");
            }
            else if (mapping.prefab == null)
            {
                 Debug.LogWarning($"BlockDatabase: Prefab for {mapping.type} is not assigned.");
            }
        }
    }

    /// <summary>
    /// 根据方块类型获取对应的预制件
    /// </summary>
    /// <param name="type">方块类型</param>
    /// <returns>对应的GameObject预制件，如果找不到则返回null</returns>
    public GameObject GetPrefab(BlockType type)
    {
        if (_database == null) OnEnable(); // 确保初始化

        _database.TryGetValue(type, out GameObject prefab);
        return prefab;
    }
}