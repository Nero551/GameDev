using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Godot;

public class Client
{
    //TODO- i need to learn how to byte-ify classes (player,peer, etc). things other than ints and bools
    //* i dont need to byte-ify the peer if i can't, its unnecessary

    public static ENetConnection Connection;

    public static ENetPacketPeer Peer;
    public static Player Player; //* the player Entity (includes camera , input, etc)
    public static int PeerId; //* this is the signature for the network connection ITSELF
    public static int UserId = 1; //* this is a signature for the player's data in DB

    private static bool Running = false;

    public static void Start()
    {
        EventService.Subscribe<Events.Remote.ClientInfo>(OnRemoteClientInfo);
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
            await Task.Delay(10);
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
                EventService.Fire(new Events.RecievedPacket(peer.GetPacket()));
                break;
            default:
                break;
        }
    }

    static void DisconnectedFromServer()
    {
        GD.Print("Disconnected To Server");
        EventService.Fire(new Events.DisconnectedFromServer());
    }

    static void ConnectedToServer()
    {
        GD.Print("Connected To Server");
        EventService.Fire(new Events.ConnectedToServer());
    }

    static void OnRemoteClientInfo(Events.Remote.ClientInfo evnt)
    {
        PeerId = evnt.PeerId;
        UserId = evnt.UserId;
    }
}
