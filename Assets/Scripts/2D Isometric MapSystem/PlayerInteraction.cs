using UnityEngine;

public class PlayerInteraction : MonoBehaviour
{
    [SerializeField] private MapManager mapManager;
    [SerializeField] private Camera mainCamera;
    [SerializeField] private float interactionDistance = 10f; // 玩家能交互的最大距离
    [SerializeField] private LayerMask interactionLayerMask; // 只与特定层级的方块交互

    [Header("Placement Settings")]
    [SerializeField] private BlockType selectedBlockType = BlockType.Stone; // 当前选中的放置方块类型
    [SerializeField] private Transform placementIndicator; // (可选) 用于显示将要放置位置的指示器
    
    private Block lastHitBlock = null; // 存储上一帧击中的方块
    
    void Start()
    {
        if (mapManager == null) mapManager = FindObjectOfType<MapManager>();
        if (mainCamera == null) mainCamera = Camera.main;

        if (mapManager == null) Debug.LogError("PlayerInteraction: MapManager 未找到!");
        if (mainCamera == null) Debug.LogError("PlayerInteraction: Main Camera 未找到!");
        if (placementIndicator != null) placementIndicator.gameObject.SetActive(false); // 初始隐藏
    }

    void Update()
    {
        Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
        RaycastHit2D hit = Physics2D.GetRayIntersection(ray, interactionDistance, interactionLayerMask);

        Block currentHitBlock = null; // 当前帧击中的方块
        if (hit.collider != null)
        {
            currentHitBlock = hit.collider.gameObject.GetComponent<Block>();
        }

        // 检查当前击中的方块是否与上一帧不同
        if (currentHitBlock != lastHitBlock)
        {
            // 如果上一帧有高亮的方块，取消它的高亮
            if (lastHitBlock != null)
            {
                lastHitBlock.OnDeselected();
            }

            // 如果当前帧击中了新的方块，高亮它
            if (currentHitBlock != null)
            {
                currentHitBlock.OnSelected();
            }

            // 更新上一帧击中的方块记录
            lastHitBlock = currentHitBlock;
        }
        // 如果射线没有击中任何东西 (currentHitBlock 为 null)，并且上一帧有高亮方块，也需要取消高亮
        else if (currentHitBlock == null && lastHitBlock != null)
        {
            lastHitBlock.OnDeselected();
            lastHitBlock = null;
        }

        HandlePlacementIndicator(); // 更新放置指示器
        HandleInteractionInput();   // 处理放置/移除输入
        HandleBlockSelectionInput(); // 处理切换方块类型输入 (示例)
    }

    private void HandleInteractionInput()
    {
        // 左键点击 - 放置方块
        if (Input.GetMouseButtonDown(0))
        {
            TryPlaceBlock();
        }

        // 右键点击 - 移除方块
        if (Input.GetMouseButtonDown(1))
        {
            TryRemoveBlock();
        }
    }

     private void HandleBlockSelectionInput()
    {
        // 示例：使用数字键 1, 2, 3 切换方块
        if (Input.GetKeyDown(KeyCode.Alpha1)) {
            selectedBlockType = BlockType.Grass;
            Debug.Log("Selected: Grass");
        } else if (Input.GetKeyDown(KeyCode.Alpha2)) {
             selectedBlockType = BlockType.Dirt;
             Debug.Log("Selected: Dirt");
        } else if (Input.GetKeyDown(KeyCode.Alpha3)) {
             selectedBlockType = BlockType.Stone;
             Debug.Log("Selected: Stone");
        } else if (Input.GetKeyDown(KeyCode.Alpha4)) {
             selectedBlockType = BlockType.Wood;
             Debug.Log("Selected: Wood");
        }
        // ... 可以扩展更多按键或使用UI来选择
    }


    private void TryPlaceBlock()
    {
        Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
        // 使用 Physics2D.GetRayIntersection 从3D射线检测2D碰撞体
        RaycastHit2D hit = Physics2D.GetRayIntersection(ray, interactionDistance, interactionLayerMask);

        if (hit.collider != null) // 检查是否击中 Collider2D
        {
            // 1. 使用 WorldToVirtual 获取射线击中点对应的虚拟坐标
            // 注意：WorldToVirtual 可能需要根据 hit.point 微调，
            // 例如稍微偏移一点进入方块内部再转换，以避免边界问题。
            // Vector3 adjustedHitPoint = hit.point - hit.normal * 0.01f; // 稍微向内偏移
            // Vector3Int hitCoord = mapManager.WorldToVirtual(adjustedHitPoint);
            // 或者直接使用 hit.point，取决于 WorldToVirtual 的实现精度
            Vector3Int hitCoord = mapManager.WorldToVirtual(hit.point);

            // 2. 计算放置位置：在击中方块的相邻位置（根据法线）
            Vector3Int placeCoord = hitCoord + Vector3Int.RoundToInt(hit.normal);

            // 3. 尝试放置
            if(mapManager.PlaceBlock(placeCoord, selectedBlockType)) {
                Debug.Log($"Placed {selectedBlockType} at {placeCoord} (adjacent to {hitCoord})");
            } else {
                // 可选：如果放置失败（例如位置已被占用），可以打印更详细的信息
                // Debug.Log($"Failed to place block at {placeCoord}. Target occupied? {mapManager.GetBlockTypeAt(placeCoord) != BlockType.Air}");
            }
        }
        else
        {
            // Debug.Log("Interaction raycast did not hit anything valid for placement.");
        }
    }

    private void TryRemoveBlock()
    {
        Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
        // 使用 Physics2D.GetRayIntersection 从3D射线检测2D碰撞体
        RaycastHit2D hit = Physics2D.GetRayIntersection(ray, interactionDistance, interactionLayerMask);

        if (hit.collider != null) // 检查是否击中 Collider2D
        {
            // 1. 使用 WorldToVirtual 获取射线击中点对应的虚拟坐标
            // 同样，可能需要微调 hit.point
            // Vector3 adjustedHitPoint = hit.point - hit.normal * 0.01f;
            // Vector3Int targetCoord = mapManager.WorldToVirtual(adjustedHitPoint);
            Vector3Int targetCoord = mapManager.WorldToVirtual(hit.collider.transform.position);
            
            Debug.Log($"{hit.collider.gameObject.name} {hit.collider.transform.position}");

            // 2. 尝试移除该坐标的方块
            if(mapManager.RemoveBlock(targetCoord)) {
                Debug.Log($"Removed block at {targetCoord}");
            } else {
                 // Debug.Log($"Failed to remove block at {targetCoord}. No block found?");
            }
        }
        else
        {
            // Debug.Log("Interaction raycast did not hit anything valid for removal.");
        }
    }

    private void HandlePlacementIndicator()
    {
        if (placementIndicator == null) return;

        Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
        RaycastHit2D hit = Physics2D.GetRayIntersection(ray, interactionDistance, interactionLayerMask);
        bool showIndicator = false;

        if (hit.collider != null)
        {
             // 1. 获取击中点对应的虚拟坐标
             // Vector3 adjustedHitPoint = hit.point - hit.normal * 0.01f;
             // Vector3Int hitCoord = mapManager.WorldToVirtual(adjustedHitPoint);
             Vector3Int hitCoord = mapManager.WorldToVirtual(hit.collider.transform.position);

             // 2. 计算潜在的放置坐标
             Vector3Int targetCoord = hitCoord + Vector3Int.RoundToInt(hit.normal);

             // 3. 检查目标位置是否为空
             if (mapManager.GetBlockTypeAt(targetCoord) == BlockType.Air)
             {
                 // 4. 如果为空，计算世界坐标并显示指示器
                 placementIndicator.position = mapManager.VirtualToWorld(targetCoord);
                 showIndicator = true;
             }
        }
        // 根据是否找到有效位置来激活/禁用指示器
        placementIndicator.gameObject.SetActive(showIndicator);
    }
}