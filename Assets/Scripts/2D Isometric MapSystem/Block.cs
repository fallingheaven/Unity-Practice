using DG.Tweening;
using UnityEngine;

public class Block : MonoBehaviour
{
    private static readonly int OutlineEnabled = Shader.PropertyToID("_Outline");

    [Tooltip("此方块在虚拟坐标系中的位置")]
    public Vector3Int virtualCoordinates;

    [Tooltip("此方块的类型")]
    public BlockType type;

    private MapManager mapManager; // 可以缓存MapManager引用提高效率
    private SpriteRenderer spriteRenderer;
    private Shader targetShader;

    void Start()
    {
        // 尝试自动查找MapManager，或者在放置时由MapManager设置
        mapManager = FindObjectOfType<MapManager>();
        spriteRenderer = GetComponent<SpriteRenderer>();
        
        if (mapManager == null)
        {
            Debug.LogError("场景中找不到MapManager!");
        }
        
        if (spriteRenderer == null)
        {
            Debug.LogError("方块缺少SpriteRenderer组件!");
        }
        else
        {
            UpdateSortingOrder();
        }
    }
    
    public void UpdateSortingOrder()
    {
        if (spriteRenderer != null)
        {
            // 根据虚拟坐标计算排序顺序
            // 公式确保更高(大z)、更远(大y或小x)的方块在下方绘制
            int sortOrder = virtualCoordinates.z * 1000 + -virtualCoordinates.y * 10 + virtualCoordinates.x;
            spriteRenderer.sortingOrder = sortOrder;
        }
    }

    private void SetOutline(bool active)
    {
        spriteRenderer.material.SetFloat(OutlineEnabled, active? 1.0f: 0.0f);
    }

    public void OnSelected()
    {
        SetOutline(true);

        transform.DOMoveY(mapManager.VirtualToWorld(virtualCoordinates).y + 0.1f, 0.2f)
            .SetEase(Ease.OutBack);
    }

    public void OnDeselected()
    {
        SetOutline(false);

        transform.DOKill();
        transform.DOMoveY(mapManager.VirtualToWorld(virtualCoordinates).y, 0.2f)
            .SetEase(Ease.OutBack);
    }

    // 你可以在这里添加方块特有的行为
    // 例如，草地蔓延、树叶腐烂等
    // public void OnNeighbourUpdate() { /* 检查邻居方块变化 */ }
    // public void TickUpdate() { /* 定时更新逻辑 */ }
}