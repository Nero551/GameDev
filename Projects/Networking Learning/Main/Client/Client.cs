using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Godot;

public static class Client
{

    //TODO- high-key i might need to switch to ECS-style framework. atleast seperate data from logic
    //* it will be easier to maintain and work with multiplayer in that framework

    //TODO- move onto replication 

    //* FOR GODOT NODES. U CAN JUST USE THE SCENE. send the filepath of the scene.
    //* even better, u can make a scene registry to assign an id to each scene. now u just send the id

    public static ENetConnection Connection;
    public static Player Player; //* the player Entity (includes camera , input, etc)
    public static int PeerId; //* this is the signature for the network connection ITSELF
    public static int UserId; //* this should go to player class

    private static bool Running = false;

    public static void Start()
    {
        EventService.Subscribe<RemoteEvents.CreatePlayer>((evnt) =>
        {
            Player player = PlayersService.CreatePlayer(evnt.UserId);
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
            Running = true;
            GD.Print("Client Started");
            Update();
        }
    }

    public static async void Update()
    {
        while (Running)
        {
            HandlePackets();
            await Task.Delay(NetworkService.PacketDebounce);
        }
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
