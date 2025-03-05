using System;
using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.UI;

public class BagManager : MonoBehaviour
{
    private GridLayoutGroup _gridLayoutGroup;

    private GameObject[] _gridArray;
    [SerializeField] private GameObject _gridPrefab;

    private const int MaxLength = 10;
    private Tuple<int, int> _bagSize = new Tuple<int, int>(2, 2);
    private BagGrid[,] _grids = new BagGrid[MaxLength, 2];

    private void Awake()
    {
        _gridLayoutGroup = GetComponent<GridLayoutGroup>();

        _gridArray = new GameObject[_bagSize.Item1 * MaxLength];
        for (var i = 0; i < _bagSize.Item1 * MaxLength; i++)
        {
            _gridArray[i] = Instantiate(_gridPrefab, transform);
            _gridArray[i].SetActive(false);
        }
    }

    private void OnEnable()
    {
        RevealBagGrid();
    }

    private void RevealBagGrid()
    {
        _gridLayoutGroup.constraintCount = _bagSize.Item1;
        
        var size = _bagSize.Item1 * _bagSize.Item2;
        for (var i = 0; i < size; i++)
        {
            _gridArray[i].SetActive(true);
            var x = i / 2;
            var y = i % 2;
            _grids[x, y] = _gridArray[i].GetComponent<BagGrid>();
        }
    }

}
