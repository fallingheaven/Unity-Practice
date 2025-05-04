// SocketClient.cs
using UnityEngine;
using System.Collections.Generic;
using SocketIOClient;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public class SocketClient : MonoBehaviour
{
    private SocketIOUnity socket;
    private string playerId;
    private int currentFrame = 0;
    private Dictionary<int, JObject> pendingFrames = new Dictionary<int, JObject>();
    
    [SerializeField] private string serverUrl = "http://localhost:3000";
    
    async void Start()
    {
        socket = new SocketIOUnity(serverUrl);
        
        // Setup event handlers
        socket.OnConnected += (sender, e) => {
            playerId = socket.Id;
            Debug.Log($"Connected as player: {playerId}");
            socket.Emit("ready");
        };
        
        socket.On("game_start", response => {
            JObject data = response.GetValue<JObject>();
            currentFrame = data["startFrame"].Value<int>();
            Debug.Log("Game started!");
        });
        
        socket.On("request_input", response => {
            JObject data = response.GetValue<JObject>();
            int frame = data["frame"].Value<int>();
            
            // Gather input
            var input = GatherPlayerInput();
            
            // Send input to server
            socket.Emit("input", new JObject {
                ["frame"] = frame,
                ["inputs"] = JObject.FromObject(input)
            });
        });
        
        socket.On("frame_update", response => {
            JObject data = response.GetValue<JObject>();
            int frame = data["frame"].Value<int>();
            JObject inputs = data["inputs"].Value<JObject>();
            
            pendingFrames[frame] = inputs;
        });
        
        await socket.ConnectAsync();
    }
    
    void Update()
    {
        // Process any pending frames in order
        if (pendingFrames.TryGetValue(currentFrame + 1, out var frameData))
        {
            ProcessFrame(currentFrame + 1, frameData);
            pendingFrames.Remove(currentFrame + 1);
            currentFrame++;
        }
    }
    
    Dictionary<string, bool> GatherPlayerInput()
    {
        return new Dictionary<string, bool> {
            {"up", Input.GetKey(KeyCode.UpArrow)},
            {"down", Input.GetKey(KeyCode.DownArrow)},
            {"left", Input.GetKey(KeyCode.LeftArrow)},
            {"right", Input.GetKey(KeyCode.RightArrow)},
            {"action", Input.GetKey(KeyCode.Space)}
        };
    }
    
    void ProcessFrame(int frame, JObject inputs)
    {
        // Process all player inputs
        foreach (var playerInput in inputs)
        {
            string id = playerInput.Key;
            JObject input = playerInput.Value.Value<JObject>();
            UpdatePlayerState(id, input);
        }
        
        // Update game physics
        UpdateGamePhysics();
    }
    
    void UpdatePlayerState(string id, JObject input)
    {
        var player = GameObject.Find(id);
        if (!player) return;
        
        var movement = Vector3.zero;
        var speed = 5f;
        
        if (input["up"].Value<bool>()) movement.y += speed * Time.deltaTime;
        if (input["down"].Value<bool>()) movement.y -= speed * Time.deltaTime;
        if (input["left"].Value<bool>()) movement.x -= speed * Time.deltaTime;
        if (input["right"].Value<bool>()) movement.x += speed * Time.deltaTime;
        
        player.transform.position += movement;
    }
    
    void UpdateGamePhysics()
    {
        // Apply physics updates
    }
    
    void OnDestroy()
    {
        socket?.Disconnect();
    }
}