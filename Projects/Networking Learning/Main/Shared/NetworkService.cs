using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Security;
using Godot;
using Godot.NativeInterop;
using Packets;

public static class NetworkService
{
    /*
        ? so how does this mess work? to send stuff from client to server first you:
        ?   1- create a packet
        ?   2- create a Remote Event to notify when packet is recieved
        ?   3- send with one of the send methods
        ?   4- subscribe a method to the Remote Event
    */
    public static Dictionary<int, Type> Packets = new() { };

    public static void Init()
    {
        RegisterPackets();
        EventService.Subscribe<Events.RecievedPacket>(OnRecievedPacket);
    }

    static void RegisterPackets()
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

    //* what i could do is have a custom event for each packet. this method just figures out which event to fire
    //* this will make using packets way easier. but setting up a packet will take longer
    static void OnRecievedPacket(Events.RecievedPacket evnt)
    {
        int senderPeerId = evnt.SenderPeerId;  // equals 0 if the server sent it
        GD.Print(senderPeerId);

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
