using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Godot;
using Packets;

public class Client
{
    public ENetConnection Connection;
    private bool Running = false;
    public void Start()
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
        Connection.ConnectToHost(Server.IP, Server.Port);
        Running = true;
        Update();
        GD.Print("Client Started");
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
        if (!NetworkService.IsClient())
            return;

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
        packetEvent = Connection.Service();
        eventType = packetEvent[0].As<ENetConnection.EventType>();
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

    void OnClientRecievedPacket(Events.ClientRecievedPacket @event)
    {
        byte[] data = @event.Data;

        Packet packet = new();

        packet.WriteBytes(data);
        packet.CreateBytesArray();
        int packetId = packet.ReadInt();

        List<Object> decodedData = packet.Decode();
        GD.Print("Nice");
        foreach (object smth in decodedData)
        {
            GD.Print(smth);
        }
    }
}
