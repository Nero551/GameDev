using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Security;
using Godot;
using Godot.NativeInterop;
using Packets;

public static class NetworkService
{

    public static Dictionary<int, Type> Packets = new() { };

    public static void Init()
    {
        RegisterPackets();
        EventService.Subscribe<Events.ServerRecievedPacket>(OnServerRecievedPacket);
        EventService.Subscribe<Events.ClientRecievedPacket>(OnClientRecievedPacket);
    }

    public static void RegisterPackets()
    {
        var packetTypes = typeof(Packet).Assembly.GetTypes().Where(t => !t.IsAbstract && typeof(Packet).IsAssignableFrom(t));

        foreach (var type in packetTypes)
        {
            Packet packet = (Packet)Activator.CreateInstance(type);

            Packets[packet.Id] = type;
        }
    }

    public static bool IsServer()
    {
        var args = OS.GetCmdlineArgs();
        if (args.Contains("Server"))
        {
            return true;
        }
        return false;
    }

    public static bool IsClient()
    {
        var args = OS.GetCmdlineArgs();
        if (args.Contains("Server"))
        {
            return false;
        }
        return true;
    }

    public static void SendToServer<T>(params object[] data) where T : Packet, new()
    {
        if (IsClient())
        {
            T packet = Packet.Create<T>(data);
            //the client only knows the server. so broadcast sends only to the server.
            Client.Connection.Broadcast(0, packet.Encode(), packet.Flag);
        }
    }

    public static void SendToClient<T>(int peerId, params object[] data) where T : Packet, new()
    {
        if (IsServer())
        {
            if (Server.ClientInfos.ContainsKey(peerId))
            {
                T packet = Packet.Create<T>(data);
                Server.ClientInfos[peerId].Peer.Send(0, packet.Encode(), packet.Flag);
            }
        }
    }

    public static void SendToAllClients<T>(params object[] data) where T : Packet, new()
    {
        if (IsServer())
        {
            T packet = Packet.Create<T>(data);
            Server.Connection.Broadcast(0, packet.Encode(), packet.Flag);
        }
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
            // GD.Print(smth);
        }
    }

    static void OnServerRecievedPacket(Events.ServerRecievedPacket evnt)
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
