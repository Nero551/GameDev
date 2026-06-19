using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Security;
using Godot;
using Godot.NativeInterop;

public static class NetworkService
{
    /*
        !So how does this mess work? to send stuff from client to server or vice versa first you:
        ?   1- create a packet
        ?   2- create a Remote Event to notify when packet is recieved
        ?   3- send with one of the send methods
        ?   4- subscribe a method to the Remote Event

        * Packets contain the Decode and Encode Methods aswell as the Remote Event they fire when sent.
        * Remote Events contain organized data recieved by the packet. the data the reciever will see.

        !Steps For Creating a Packet:
        ?   1- create a new class inheriting Packet.
        ?   2- assign the Flag of the packet (Reliable, Unreliable, etc).
        ?   3- override Encode, Decode & FireRemote methods to suit the packet's data

        !Steps For Creating a Remote:
        ?   1- create a new class inheriting Remote
        ?   2- create a constructor with parameters (int senderPeerId, object[] decodedData)
        ?   3- assign the base fields SenderPeerId and DecodedData to the parameters
        ?   4- create new fields and assign them to values in the DecodedData Array (differs per remote) 
    */

    public static int PacketDebounce = 10; // The delay on handling packets in milliseconds
    public static Dictionary<int, Type> Packets = [];
    public static Dictionary<Type, int> IdPacketLookup = [];

    public static void Init()
    {
        RegisterPackets();
        EventService.Subscribe<Events.RecievedPacket>(OnRecievedPacket);
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

    static void OnRecievedPacket(Events.RecievedPacket evnt)
    {
        int senderPeerId = evnt.SenderPeerId;  // equals 0 if the server sent it
        byte[] data = evnt.Data;
        int packetId = Packet.ReadPacketId(data);

        Packet packet = (Packet)Activator.CreateInstance(NetworkService.Packets[packetId]);
        packet.WriteBytes(data);
        packet.CreateBytesArray();
        object[] decodedData = packet.Decode();

        packet.FireRemote(senderPeerId, decodedData);
    }

    static void RegisterPackets()
    {
        int currentId = 1;
        var packetTypes = typeof(Packet).Assembly.GetTypes().Where(
            t => !t.IsAbstract && typeof(Packet).IsAssignableFrom(t)
            ).OrderBy(t => t.Name);

        foreach (var type in packetTypes)
        {
            Packet packet = (Packet)Activator.CreateInstance(type);

            IdPacketLookup[type] = currentId;
            Packets[currentId] = type;
            currentId++;
        }
    }
}
