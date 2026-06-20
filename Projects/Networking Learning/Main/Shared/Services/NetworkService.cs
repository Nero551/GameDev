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
        ?   1- create a RemoteEvent class inheriting RemoteEvent.
        ?   2- assign the Flag of the remote event (Reliable, Unreliable, etc).
        ?   3- override Encode to write the data sent over the network.
        ?   4- override Decode to read the data into fields.
        ?   5- send with one of the send methods.
        ?   6- subscribe a method to the RemoteEvent type.

        * RemoteEvents contain both the networking logic and the organized data the reciever will see.
        * NetworkService fires the RemoteEvent after Decode finishes.
        * SenderPeerId is assigned before Decode runs. It equals 0 if the server sent the remote event.
    */

    public static int PacketDebounce = 5; // The delay on handling packets in milliseconds
    public static BidirectionalDictionary<int, Type> RemoteEvents = new();

    public static void Init()
    {
        RegisterRemoteEvents();
        EventService.Subscribe<Events.Network.RecievedPacket>(OnRecievedPacket);
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

    public static void SendToServer<T>(params object[] data) where T : RemoteEvent, new()
    {
        if (IsClient())
        {
            T remoteEvent = RemoteEvent.Create<T>(data);
            //the client only knows the server. so broadcast sends only to the server.
            Client.Connection.Broadcast(0, remoteEvent.Encode(), remoteEvent.Flag);
        }
    }

    public static void SendToClient<T>(int peerId, params object[] data) where T : RemoteEvent, new()
    {
        if (IsServer())
        {
            if (Server.ClientInfos.ContainsKey(peerId))
            {
                T remoteEvent = RemoteEvent.Create<T>(data);
                Server.ClientInfos[peerId].Peer.Send(0, remoteEvent.Encode(), remoteEvent.Flag);
            }
        }
    }

    public static void SendToAllClients<T>(params object[] data) where T : RemoteEvent, new()
    {
        if (IsServer())
        {
            T remoteEvent = RemoteEvent.Create<T>(data);
            Server.Connection.Broadcast(0, remoteEvent.Encode(), remoteEvent.Flag);
        }
    }

    static void OnRecievedPacket(Events.Network.RecievedPacket evnt)
    {
        int senderPeerId = evnt.SenderPeerId;  // equals 0 if the server sent it
        byte[] data = evnt.Data;
        int remoteEventId = RemoteEvent.ReadRemoteEventId(data);

        RemoteEvent remoteEvent = (RemoteEvent)Activator.CreateInstance(NetworkService.RemoteEvents.GetByKey(remoteEventId));
        remoteEvent.WriteBytes(data);
        remoteEvent.CreateBytesArray();

        remoteEvent.SenderPeerId = senderPeerId;
        remoteEvent.Decode();
        remoteEvent.Fire();
    }

    static void RegisterRemoteEvents()
    {
        int currentId = 1;
        var remoteEventTypes = typeof(RemoteEvent).Assembly.GetTypes().Where(
            t => !t.IsAbstract && typeof(RemoteEvent).IsAssignableFrom(t)
            ).OrderBy(t => t.Name);

        foreach (var type in remoteEventTypes)
        {
            RemoteEvents.Add(currentId, type);
            currentId++;
        }
    }
}
