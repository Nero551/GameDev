using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Godot;

public class Client
{
    //TODO- need way for the Client class and Player Class to be connected.
    /*
        * am thinking make the server send back a packet containing the peer id and peer,
        * after the "ClientConnected" server event.

        * it just hit me . there is only 1 client per client instance. that means it can be static.
        * same with server .the instance that has server only has 1 server.
        * the server only contains the Client's player. it can't own the client. the client is on its own instanc
    */

    public static ENetConnection Connection;

    public static ENetPacketPeer Peer;
    public static Player Player; //* the player Entity (includes camera , input, etc)
    public static int PeerId; //* this is the signature for the network connection ITSELF
    public static int UserId = 1; //* this is a signature for the player's data in DB
    
    private static bool Running = false;

    public static void Start()
    {
        if (NetworkService.IsClient())
        {
            EventService.Subscribe<Events.ClientRecievedPacket>(OnClientRecievedPacket);
            Connection = new ENetConnection();
            Error error = Connection.CreateHost(1);
            if (error != default)
            {
                GD.Print($"Client Failed To Start: {error}");
                Connection = null;
                return;
            }
            //TODO- tis is same issue. client should't access server like that.
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
                EventService.Fire(new Events.ClientRecievedPacket(peer.GetPacket()));
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

    static void OnClientRecievedPacket(Events.ClientRecievedPacket evnt)
    {
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
