using UnityEngine;
using System.Collections.Generic;

public class SimpleLightning : MonoBehaviour
{
    [Header("Settings")]
    public int maxIterations = 50;
    public float branchChance = 0.3f;
    public float jitter = 0.5f;
    public float segmentLength = 0.2f;
    
    [Header("References")]
    public LineRenderer lineRenderer;
    public Transform startPoint;
    public Transform endPoint;

    private List<Vector3> _pathPoints = new List<Vector3>();

    void GeneratePath()
    {
        _pathPoints.Clear();
        Vector3 currentPos = startPoint.position;
        Vector3 targetDir = (endPoint.position - startPoint.position).normalized;

        _pathPoints.Add(currentPos);

        for(int i=0; i<maxIterations; i++){
            // 基础方向
            Vector3 newDir = Vector3.Lerp(targetDir, Random.onUnitSphere, jitter).normalized;
            
            // 分支逻辑
            if(Random.value < branchChance){
                Vector3 branchDir = Vector3.Lerp(newDir, Random.onUnitSphere, 0.7f).normalized;
                GenerateBranch(currentPos, branchDir, 0);
            }

            currentPos += newDir * segmentLength;
            _pathPoints.Add(currentPos);

            if(Vector3.Distance(currentPos, endPoint.position) < 0.5f) break;
        }

        UpdateLineRenderer();
    }

    void GenerateBranch(Vector3 startPos, Vector3 direction, int depth)
    {
        if(depth > 3) return;
        
        List<Vector3> branchPoints = new List<Vector3>();
        Vector3 currentPos = startPos;
        
        for(int i=0; i<5; i++){
            currentPos += direction * segmentLength * 0.5f;
            branchPoints.Add(currentPos);
            direction = Vector3.Lerp(direction, Random.onUnitSphere, 0.3f).normalized;
        }
        
        lineRenderer.positionCount += branchPoints.Count;
        lineRenderer.SetPositions(branchPoints.ToArray());
    }

    void UpdateLineRenderer()
    {
        lineRenderer.positionCount = _pathPoints.Count;
        lineRenderer.SetPositions(_pathPoints.ToArray());
    }

    void Update()
    {
        if(Input.GetKeyDown(KeyCode.Space)){
            GeneratePath();
        }
    }
}