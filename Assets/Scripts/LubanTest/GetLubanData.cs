using System.Collections;
using System.Collections.Generic;
using System.IO;
using SimpleJSON;
using UnityEngine;
using cfg;

public class GetLubanData : MonoBehaviour
{
    void Start()
    {
        var gameConfDir = "Assets/Config/output/data"; // 替换为gen.bat中outputDataDir指向的目录
        var tables = new Tables(file => JSON.Parse(File.ReadAllText($"{gameConfDir}/{file}.json")));
        Debug.Log($"{tables.TbItem.Get(10003).Quality}");
    }
    
}
