using UnityEngine;
using System.Collections.Generic;
using UnityEngine.Serialization;

public class MapManager : MonoBehaviour
{
    [Header("Configuration")]
    [SerializeField] private BlockDatabase blockDatabase; // 拖拽你的BlockDatabase资源到这里
    [Tooltip("每个方块在世界空间的基础视觉尺寸")]
    [SerializeField] private Vector3 tileSize = new Vector3(1f, 0.5f, 1f); // X宽, Y高, Z深 (视觉上的)
    [Tooltip("世界坐标原点偏移量")]
    [SerializeField] private Vector3 originOffset = Vector3.zero;
    [Tooltip("父对象，所有方块实例将放在其下")]
    [SerializeField] private Transform blocksParent;

    [Header("World Data")]
    // 使用字典存储已放置的方块实例，键是虚拟坐标
    private Dictionary<Vector3Int, GameObject> blockInstances = new Dictionary<Vector3Int, GameObject>();

    // --- 核心功能 ---

    void Start()
    {
        if (blockDatabase == null) {
            Debug.LogError("MapManager: BlockDatabase未分配!");
            return;
        }
        if (blocksParent == null) {
            blocksParent = this.transform; // 默认放在自己下面
            Debug.LogWarning("MapManager: Blocks Parent 未指定，使用 MapManager 自身。");
        }

        // --- 伪代码：世界生成/加载 ---
        GenerateInitialWorld();
        // OR
        // LoadWorldData("mySaveFile");
        // --- 结束伪代码 ---
    }

    /// <summary>
    /// 将虚拟3D坐标转换为Unity世界坐标
    /// </summary>
    public Vector3 VirtualToWorld(Vector3Int virtualCoord)
    {
        // 使用之前讨论的等距转换逻辑
        Vector3 xBase = new Vector3(0.5f * tileSize.x, -0.5f * tileSize.y, 0);
        Vector3 yBase = new Vector3(0.5f * tileSize.x, 0.5f * tileSize.y, 0);
        Vector3 zBase = new Vector3(0, tileSize.y, -1); // 虚拟Z直接影响世界Y

        Vector3 worldPosition = (virtualCoord.x * xBase) +
                                (virtualCoord.y * yBase) +
                                (virtualCoord.z * zBase) +
                                originOffset;
        
        // Debug.Log($"{virtualCoord} 转换为世界坐标: {worldPosition}");
        return worldPosition;
    }

    /// <summary>
    /// 将Unity世界坐标转换为最接近的虚拟3D坐标（用于拾取等）
    /// </summary>
    public Vector3Int WorldToVirtual(Vector3 worldPosition)
    {
        // 移除原点偏移
        Vector3 relativePos = worldPosition - originOffset;
    
        // 虚拟Z是世界z的负值
        int virtualZ = Mathf.RoundToInt(-relativePos.z);
    
        // 从世界y中减去z的贡献
        float yWithoutZ = relativePos.y - (virtualZ * tileSize.y);
    
        // 解方程组:
        // worldX = 0.5f * tileSize.x * (virtualX + virtualY)
        // yWithoutZ = (xyRatio * 0.5f) * tileSize.y * (virtualY - virtualX)
    
        float sumXY = relativePos.x / (0.5f * tileSize.x);
        float diffYX = yWithoutZ / (0.5f * tileSize.y);
    
        int virtualX = Mathf.RoundToInt((sumXY - diffYX) / 2);
        int virtualY = Mathf.RoundToInt((sumXY + diffYX) / 2);
        
        Debug.Log($"{worldPosition} 转换为虚拟坐标: {virtualX}, {virtualY}, {virtualZ}");
    
        return new Vector3Int(virtualX, virtualY, virtualZ);
    }


    /// <summary>
    /// 在指定的虚拟坐标放置一个方块
    /// </summary>
    /// <param name="virtualCoord">要放置的虚拟坐标</param>
    /// <param name="type">要放置的方块类型</param>
    /// <returns>放置成功则返回true，否则返回false</returns>
    public bool PlaceBlock(Vector3Int virtualCoord, BlockType type)
    {
        // 不能放置空气方块 (空气代表没有方块)
        if (type == BlockType.Air)
        {
            // 如果这里已经有方块，则移除它
            return RemoveBlock(virtualCoord);
        }

        // 检查是否已存在方块
        if (blockInstances.ContainsKey(virtualCoord))
        {
            Debug.Log($"坐标 {virtualCoord} 已存在方块，无法放置。");
            return false;
        }

        GameObject prefab = blockDatabase.GetPrefab(type);
        if (prefab == null)
        {
            Debug.LogError($"找不到类型 {type} 的方块预制件。");
            return false;
        }

        Vector3 worldPosition = VirtualToWorld(virtualCoord);
        GameObject newBlockInstance = Instantiate(prefab, worldPosition, Quaternion.identity, blocksParent);
        newBlockInstance.name = $"{type}_{virtualCoord.x}_{virtualCoord.y}_{virtualCoord.z}";

        // 设置方块脚本信息
        Block blockScript = newBlockInstance.GetComponent<Block>();
        if (blockScript != null)
        {
            blockScript.virtualCoordinates = virtualCoord;
            blockScript.type = type; // 确保类型也设置正确
        }
        else
        {
            Debug.LogError($"放置的预制件 {prefab.name} 缺少Block脚本!");
            Destroy(newBlockInstance); // 清理错误的实例
            return false;
        }

        // 存储实例
        blockInstances.Add(virtualCoord, newBlockInstance);

        // --- 伪代码：通知邻居方块更新 ---
        // NotifyNeighboursOfChange(virtualCoord);
        // --- 结束伪代码 ---

        return true;
    }

    /// <summary>
    /// 移除指定虚拟坐标的方块
    /// </summary>
    /// <param name="virtualCoord">要移除方块的虚拟坐标</param>
    /// <returns>移除成功则返回true，否则返回false</returns>
    public bool RemoveBlock(Vector3Int virtualCoord)
    {
        if (blockInstances.TryGetValue(virtualCoord, out GameObject blockToRemove))
        {
            Destroy(blockToRemove);
            blockInstances.Remove(virtualCoord);

            // --- 伪代码：通知邻居方块更新 ---
            // NotifyNeighboursOfChange(virtualCoord);
            // --- 结束伪代码 ---

            return true;
        }
        
        Debug.Log($"坐标 {virtualCoord} 没有方块可移除。");
        return false;
    }

    /// <summary>
    /// 获取指定虚拟坐标的方块类型
    /// </summary>
    public BlockType GetBlockTypeAt(Vector3Int virtualCoord)
    {
        if (blockInstances.TryGetValue(virtualCoord, out GameObject instance))
        {
            Block block = instance.GetComponent<Block>();
            if (block != null)
            {
                return block.type;
            }
        }
        return BlockType.Air; // 默认是空气
    }

     /// <summary>
    /// 获取指定虚拟坐标的方块GameObject实例
    /// </summary>
    public GameObject GetBlockInstanceAt(Vector3Int virtualCoord)
    {
        blockInstances.TryGetValue(virtualCoord, out GameObject instance);
        return instance;
    }


    // --- 伪代码区域 ---

    private void GenerateInitialWorld()
    {
        Debug.Log("Generating initial flat world...");
        int worldSize = 10; // 示例大小
        for (int x = -worldSize; x <= worldSize; x++)
        {
            for (int y = -worldSize; y <= worldSize; y++)
            {
                // 创建一个基础平面 (Vz = 0)
                PlaceBlock(new Vector3Int(x, y, 0), BlockType.Grass);
                 // 可以在上面随机加点东西
                 if (Random.value < 0.1f) {
                     PlaceBlock(new Vector3Int(x, y, 1), BlockType.Stone);
                     if (Random.value < 0.5f) {
                         PlaceBlock(new Vector3Int(x, y, 2), BlockType.Stone);
                     }
                 }
            }
        }
        Debug.Log("Initial world generated.");
    }

    // public void LoadWorldData(string filename) { /* 从文件加载 blockInstances 数据 */ }
    // public void SaveWorldData(string filename) { /* 将 blockInstances 数据保存到文件 */ }
    // public void NotifyNeighboursOfChange(Vector3Int coord) { /* 获取周围6个邻居并调用它们的 OnNeighbourUpdate() */ }

    // --- 结束伪代码区域 ---
}