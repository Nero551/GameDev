using System;
using System.Linq;
using Godot;

/// <summary>
/// Provides packet routing, remote event registration, and client/server communication.
/// </summary>
/// <remarks>
/// Workflow:
/// 1. Create a class inheriting RemoteEvent.
/// 2. Specify the packet flag (Reliable, Unreliable, etc).
/// 3. Override Encode() to write outgoing data.
/// 4. Override Decode() to read incoming data.
/// 5. Send the event using one of the Send methods.
/// 6. Subscribe to the event type through EventService.
///
/// RemoteEvents contain both the networking logic and the data visible to receivers.
/// NetworkService automatically fires the RemoteEvent after Decode() completes.
/// SenderPeerId is assigned before Decode() runs and equals 0 when sent by the server.
/// </remarks>
/// 
public static class NetworkService
{ 
    public static int PacketDebounce = 5;

    public static BiDictionary<int, Type> RemoteEvents = new();

    public static void Start()
    {
        RegisterRemoteEvents();
        RemoteEvent.RegisterEnDecoding();
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

    public static void SendToServer<T>(params object[] data)
        where T : RemoteEvent, new()
    {
        if (IsClient())
        {
            T remoteEvent = RemoteEvent.Create<T>(data);
            Client.Connection.Broadcast(0, remoteEvent.Encode(), remoteEvent.Flag);
        }
    }

    public static void SendToClient<T>(int peerId, params object[] data)
        where T : RemoteEvent, new()
    {
        if (IsServer())
        {
            if (Server.ClientInfos.ContainsKey(peerId))
            {
                T remoteEvent = RemoteEvent.Create<T>(data);
                Server.ClientInfos[peerId].Peer.Send(
                    0,
                    remoteEvent.Encode(),
                    remoteEvent.Flag);
            }
        }
    }

    public static void SendToAllClients<T>(params object[] data)
        where T : RemoteEvent, new()
    {
        if (IsServer())
        {
            T remoteEvent = RemoteEvent.Create<T>(data);
            Server.Connection.Broadcast(
                0,
                remoteEvent.Encode(),
                remoteEvent.Flag);
        }
    }

    static void OnRecievedPacket(Events.Network.RecievedPacket evnt)
    {
        int senderPeerId = evnt.SenderPeerId;
        byte[] data = evnt.Data;
        int remoteEventId = RemoteEvent.ReadRemoteEventId(data);

        RemoteEvent remoteEvent =
            (RemoteEvent)Activator.CreateInstance(
                NetworkService.RemoteEvents.GetByKey(remoteEventId));

        remoteEvent.WriteBytes(data);
        remoteEvent.CreateBytesArray();

        remoteEvent.SenderPeerId = senderPeerId;
        remoteEvent.Decode();
        remoteEvent.Fire();
    }

    static void RegisterRemoteEvents()
    {
        int currentId = 1;

        var remoteEventTypes =
            typeof(RemoteEvent)
                .Assembly
                .GetTypes()
                .Where(t =>
                    !t.IsAbstract &&
                    typeof(RemoteEvent).IsAssignableFrom(t))
                .OrderBy(t => t.Name);

        foreach (var type in remoteEventTypes)
        {
            RemoteEvents.Add(currentId, type);
            currentId++;
        }
    }
}
