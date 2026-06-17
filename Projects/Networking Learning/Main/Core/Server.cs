using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Godot;

public partial class Server
{
    //TODO- learn godot networking, make networking serice wrapper to make using godot multiplayer easier.

    public static int Port = 7777;
    public static string IP = "127.0.0.1";
    public static Dictionary<int, Player> Clients = [];
    public static ENetPacketPeer ServerPeer;
    public static ENetConnection Connection;

    private bool Running = false;
    private readonly int MaxClients = 12;
    private readonly List<int> AvailableIds = System.Linq.Enumerable.Range(256, 2).Reverse().ToList();

    public void Start()
    {
        if (NetworkService.IsServer())
        {
            EventService.Subscribe<Events.ServerRecievedPacket>(OnServerRecievedPacket);
            Connection = new ENetConnection();
            Error error = Connection.CreateHostBound(IP, Port, MaxClients);
            if (error != default)
            {
                GD.Print($"Server Failed To Start: {error}");
                Connection = null;
                return;
            }
            Running = true;
            GD.Print("Server Started");
            Update();
        }
    }

    public async void Update()
    {
        while (Running)
        {
            HandlePackets();
            await Task.Delay(10);
        }
    }

    private void HandlePackets()
    {
        var packetEvent = Connection.Service();
        ENetConnection.EventType eventType = packetEvent[0].As<ENetConnection.EventType>();
        var peer = packetEvent[1].As<ENetPacketPeer>();

        switch (eventType)
        {
            case ENetConnection.EventType.Error:
                GD.PushWarning("Packet Resulted in Unknown Error!");
                break;
            case ENetConnection.EventType.Connect:
                ClientConnected(peer);
                break;
            case ENetConnection.EventType.Disconnect:
                ClientDisconnected(peer);
                break;
            case ENetConnection.EventType.Receive:
                EventService.Fire(new Events.ServerRecievedPacket(((Player)peer.GetMeta("Player")).UserId, peer.GetPacket()));
                break;
            default:
                break;
        }
    }

    Player CreatePlayer(ENetPacketPeer peer, int clientId)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/Scenes/player.tscn");
        Player player = scene.Instantiate<Player>();
        player.Peer = peer;
        player.UserId = clientId;
        player.Name = clientId.ToString();
        Game.game.AddChild(player);
        return player;
    }

    void ClientConnected(ENetPacketPeer peer)
    {
        int clientId = AvailableIds[AvailableIds.Count - 1];
        AvailableIds.RemoveAt(AvailableIds.Count - 1);

        Player player = CreatePlayer(peer, clientId);
        peer.SetMeta("Player", player);
        Clients[clientId] = player;

        GD.Print($"Client Connected With ID {player.UserId}");
        EventService.Fire(new Events.ClientConnected(player.UserId));
    }

    void ClientDisconnected(ENetPacketPeer client)
    {
        Player player = (Player)client.GetMeta("Player");
        int userId = player.UserId;
        AvailableIds.Add(userId);
        Clients.Remove(userId);
        player.QueueFree();

        GD.Print($"Client Disconnected With ID {userId}");
        EventService.Fire(new Events.ClientDisconnected(userId));
    }

    void OnServerRecievedPacket(Events.ServerRecievedPacket evnt)
    {
        int clientId = evnt.ClientId;
        byte[] data = evnt.Data;
        int packetId = Packet.ReadPacketId(data);
        
        Packet packet = (Packet)Activator.CreateInstance(NetworkService.Packets[packetId]);
        packet.WriteBytes(data);
        packet.CreateBytesArray();

        List<Object> decodedData = packet.Decode();

        foreach (object smth in decodedData)
        {
            GD.Print(smth);
        }
    }
}
