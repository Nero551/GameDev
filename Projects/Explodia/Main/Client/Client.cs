using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Godot;

public static class Client
{
    public static ENetConnection Connection;
    public static Entities.Player Player;
    public static int PeerId; //* this is the signature for the network connection ITSELF
    public static int UserId; //* the entry to the client's data in the DB

    public static void Start()
    {
        EventService.Subscribe<RemoteEvents.CreatePlayer>((evnt) =>
        {
            Entities.Player player = PlayersService.CreatePlayer(evnt.UserId);
            if (UserId == evnt.UserId)
            {
                Player = player;
            }
        });
        EventService.Subscribe<RemoteEvents.RemovePlayer>((evnt) => PlayersService.RemovePlayer(evnt.UserId));

        EventService.Subscribe<RemoteEvents.ClientInfo>(OnClientInfo);
        if (NetworkService.IsClient())
        {
            Connection = new ENetConnection();
            Error error = Connection.CreateHost(1);
            if (error != default)
            {
                GD.Print($"Client Failed To Start: {error}");
                Connection = null;
                return;
            }
            Connection.ConnectToHost(Server.IP, Server.Port);
            GD.Print("Client Started");
        }
    }

    public static void Process(double delta)
    {
        HandlePackets();
    }

    static void HandlePackets()
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
                ConnectedToServer();
                break;
            case ENetConnection.EventType.Disconnect:
                DisconnectedFromServer();
                return;
            case ENetConnection.EventType.Receive:
                EventService.Fire(new Events.Network.RecievedPacket(peer.GetPacket()));
                break;
            default:
                break;
        }
    }

    static void DisconnectedFromServer()
    {
        GD.Print("Disconnected From Server");
        EventService.Fire(new Events.Network.DisconnectedFromServer());
    }

    static void ConnectedToServer()
    {
        GD.Print("Connected To Server");
    }

    static void OnClientInfo(RemoteEvents.ClientInfo evnt)
    {
        PeerId = evnt.PeerId;
        UserId = evnt.UserId;
        foreach (int playerId in evnt.PlayerIds)
        {
            if (playerId != UserId)
            {
                PlayersService.CreatePlayer(playerId);
            }
        }
        EventService.Fire(new Events.Network.ConnectedToServer());
    }
}
