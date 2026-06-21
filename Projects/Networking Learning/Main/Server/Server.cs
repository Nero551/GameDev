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
        public Entities.Player Player;
        public ENetPacketPeer Peer;
    }

    public static int Port = 7777;
    public static string IP = "127.0.0.1";
    public static Dictionary<int, ClientInfo> ClientInfos = [];
    public static ENetConnection Connection;

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
            GD.Print("Server Started");
        }
    }

    public static void Process(double delta)
    {
            HandlePackets();
    }

    private static void HandlePackets()
    {
        while (true)
        {
            var packetEvent = Connection.Service();
            ENetConnection.EventType eventType = packetEvent[0].As<ENetConnection.EventType>();

            if (eventType == ENetConnection.EventType.None)
            {
                break;
            }

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
                        new Events.Network.RecievedPacket(
                            peer.GetPacket(), ((ClientInfo)peer.GetMeta("ClientInfo")).PeerId
                            )
                        );
                    break;
                default:
                    break;
            }
        }
    }

    static void ClientConnected(ENetPacketPeer peer)
    {
        int peerId = AvailableIds[^1];
        AvailableIds.RemoveAt(AvailableIds.Count - 1);


        ClientInfo clientInfo = new()
        {
            UserId = peerId,
            PeerId = peerId,
            Peer = peer
        };
        clientInfo.Player = PlayersService.CreatePlayer(clientInfo.UserId);

        peer.SetMeta("ClientInfo", clientInfo);
        ClientInfos[peerId] = clientInfo;

        NetworkService.SendToClient<RemoteEvents.ClientInfo>(peerId, clientInfo, PlayersService.Players.Keys.ToArray());
        NetworkService.SendToAllClients<RemoteEvents.CreatePlayer>(clientInfo.UserId);
        GD.Print($"Client Connected With ID {peerId}");
        EventService.Fire(new Events.Network.ClientConnected(peerId));
    }

    static void ClientDisconnected(ENetPacketPeer client)
    {
        ClientInfo clientInfo = (ClientInfo)client.GetMeta("ClientInfo");
        AvailableIds.Add(clientInfo.PeerId);
        ClientInfos.Remove(clientInfo.PeerId);
        PlayersService.RemovePlayer(clientInfo.UserId);

        NetworkService.SendToAllClients<RemoteEvents.RemovePlayer>(clientInfo.UserId);
        GD.Print($"Client Disconnected With ID {clientInfo.PeerId}");
        EventService.Fire(new Events.Network.ClientDisconnected(clientInfo.PeerId));
    }
}
