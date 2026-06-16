using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

public partial class Server : Node
{
    //TODO- learn godot networking, make networking serice wrapper to make using godot multiplayer easier.

    public static int Port = 7777;
    public static string IP = "127.0.0.1";
    private int MaxClients = 12;
    private readonly List<int> AvailableIds = System.Linq.Enumerable.Range(256, 0).Reverse().ToList();

    public Dictionary<int, Player> Clients = [];
    public ENetPacketPeer ServerPeer;

    public void Start()
    {
        if (NetworkService.IsServer())
        {
            NetworkService.Connection = new ENetConnection();
            Error error = NetworkService.Connection.CreateHostBound(IP, Port, MaxClients);
            if (error != default)
            {
                GD.Print($"Server Failed To Start: {error}");
                NetworkService.Connection = null;
                return;
            }
            GD.Print("Server Started");
        }
    }

    public override void _Process(double delta)
    {
        base._Process(delta);
        HandlePackets();

    }
    private void HandlePackets()
    {
        if (!NetworkService.IsServer())
            return;

        var packetEvent = NetworkService.Connection.Service();
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
        packetEvent = NetworkService.Connection.Service();
        eventType = packetEvent[0].As<ENetConnection.EventType>();
    }

    Player CreatePlayer(ENetPacketPeer client, int clientId)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/Scenes/player.tscn");
        Player player = scene.Instantiate<Player>();
        player.UserId = clientId;
        player.Client = client;
        player.Name = clientId.ToString();
        Game.game.AddChild(player);
        return player;
    }

    void ClientConnected(ENetPacketPeer client)
    {
        int clientId = AvailableIds[AvailableIds.Count - 1];
        AvailableIds.RemoveAt(AvailableIds.Count - 1);

        Player player = CreatePlayer(client, clientId);
        client.SetMeta("Player", player);
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
}
