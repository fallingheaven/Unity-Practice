using System;
using UnityEngine;
using UnityEngine.Tilemaps;

public class TileMapManager : MonoBehaviour
{
    public Tilemap mainTilemap;
    public Camera mainCamera;

    public GameObject tileBaseObj;

    private void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            // Debug.Log("Click");
            
            var pos = mainCamera.ScreenToWorldPoint(Input.mousePosition);
            Debug.Log($"{pos}");
            
            var intPos = new Vector3Int(Mathf.FloorToInt(pos.x), Mathf.FloorToInt(pos.y), 
                Mathf.FloorToInt(mainTilemap.transform.position.z));
            Debug.Log($"{intPos}");
            
            var targetTile = mainTilemap.GetTile(intPos);
            
            if (targetTile)
            {
                var data = new TileData();
                targetTile.GetTileData(intPos, mainTilemap, ref data);
                // if (!data.gameObject)
                // {
                //     data.gameObject = GameObject.Instantiate(tileBaseObj);
                //     data.gameObject.GetComponent<SpriteRenderer>().sprite = data.sprite; 
                // }
                Debug.Log($"{data.gameObject}");
            }
            
        }
    }
}
