// 定义所有可能的方块类型
public enum BlockType
{
    Air = 0, // 代表空，通常不实例化GameObject
    Grass,
    Dirt,
    Stone,
    Wood,
    Leaves,
    Water // 水可能需要特殊处理（如不同的物理或渲染）
    // ... 添加更多你需要的方块类型
}