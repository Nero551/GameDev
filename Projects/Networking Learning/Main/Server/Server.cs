using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Godot;
using Godot.NativeInterop;
using Microsoft.VisualBasic;

public static partial class Server
{
    public partial class ClientInfo : GodotObject
    {
        public int UserId;
        public int PeerId;
        public ENetPacketPeer Peer;
        public Player Player;
    }
    public static int Port = 7777;
    public static string IP = "127.0.0.1";
    public static Dictionary<int, ClientInfo> ClientInfos = [];
    public static ENetConnection Connection;

    private static bool Running = false;
    private static readonly int MaxClients = 12;
    private static readonly List<int> AvailableIds = [.. System.Linq.Enumerable.Range(1, 12).Reverse()];

    public static void Start()
    {
        if (NetworkService.IsServer())
        {
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

    public static async void Update()
    {
        while (Running)
        {
            HandlePackets();
            await Task.Delay(10);
        }
    }

    private static void HandlePackets()
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
                EventService.Fire(
                    new Events.ServerRecievedPacket(
                        ((ClientInfo)peer.GetMeta("ClientInfo")).PeerId, peer.GetPacket()
                        )
                    );
                break;
            default:
                break;
        }
    }

    static Player CreatePlayer(ClientInfo clientInfo)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/Shared/Scenes/player.tscn");
        Player player = scene.Instantiate<Player>();
        player.Name = clientInfo.UserId.ToString();
        Game.game.AddChild(player);
        return player;
    }

    static void ClientConnected(ENetPacketPeer peer)
    {
        int peerId = AvailableIds[^1];
        AvailableIds.RemoveAt(AvailableIds.Count - 1);


        ClientInfo clientInfo = new()
        {
            PeerId = peerId,
            Peer = peer
        };
        clientInfo.Player = CreatePlayer(clientInfo);
        peer.SetMeta("ClientInfo", clientInfo);
        ClientInfos[peerId] = clientInfo;

        NetworkService.SendToClient<Packets.ClientInfo>(peerId, clientInfo);

        GD.Print($"Client Connected With ID {peerId}");
        EventService.Fire(new Events.ClientConnected(peerId));
    }

    static void ClientDisconnected(ENetPacketPeer client)
    {
        ClientInfo clientInfo = (ClientInfo)client.GetMeta("ClientInfo");
        AvailableIds.Add(clientInfo.PeerId);
        ClientInfos.Remove(clientInfo.PeerId);
        clientInfo.Player.QueueFree();

        GD.Print($"Client Disconnected With ID {clientInfo.PeerId}");
        EventService.Fire(new Events.ClientDisconnected(clientInfo.PeerId));
    }
}
