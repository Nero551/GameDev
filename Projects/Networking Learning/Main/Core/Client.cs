using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Godot;

public class Client
{
    //TODO- need way for the Client class and Player Class to be connected.
    /*
        *when they are connected the peer will exist here , making it much easier to do anything basically.
        * and client class will contain player field. making comms between them easier to work with.
        * the clientt class should OWN the player.

        * I COULD MAKE THIS CLIENT CLASS INHERITTT EnetPacketPeer
    */
    private ENetConnection Connection;
    private bool Running = false;

    public void Start()
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
            Server.ServerPeer = Connection.ConnectToHost(Server.IP, Server.Port);
            Running = true;
            Update();
            GD.Print("Client Started");
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

    void HandlePackets()
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

    void DisconnectedFromServer()
    {
        GD.Print("Disconnected To Server");
        EventService.Fire(new Events.DisconnectedFromServer());
    }

    void ConnectedToServer()
    {
        GD.Print("Connected To Server");
        EventService.Fire(new Events.ConnectedToServer());
    }

    void OnClientRecievedPacket(Events.ClientRecievedPacket evnt)
    {
        byte[] data = evnt.Data;
        int packetId = Packet.ReadPacketId(data);

        Packet packet = (Packet)Activator.CreateInstance(NetworkService.Packets[packetId]);
        packet.WriteBytes(data);
        packet.CreateBytesArray();

        List<Object> decodedData = packet.Decode();
        foreach (object smth in decodedData)
        {
            GD.Print(smth );
        }
    }
}
