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
    /// <summary>
    /// Delay in milliseconds between packet processing operations.
    /// </summary>
    /// 
    public static int PacketDebounce = 5;

    /// <summary>
    /// Maps registered RemoteEvent types to their network IDs.
    /// </summary>
    /// 
    public static BiDictionary<int, Type> RemoteEvents = new();

    /// <summary>
    /// Initializes the networking layer and registers all RemoteEvents.
    /// </summary>
    /// 
    public static void Init()
    {
        RegisterRemoteEvents();
        EventService.Subscribe<Events.Network.RecievedPacket>(OnRecievedPacket);
    }

    /// <summary>
    /// Determines whether the current process is running as a server.
    /// </summary>
    /// <returns>
    /// True if launched with the "Server" command line argument.
    /// </returns>
    /// 
    public static bool IsServer()
    {
        var args = OS.GetCmdlineArgs();
        if (args.Contains("Server"))
        {
            return true;
        }
        return false;
    }

    /// <summary>
    /// Determines whether the current process is running as a client.
    /// </summary>
    /// <returns>
    /// True if not launched as a server.
    /// </returns>
    /// 
    public static bool IsClient()
    {
        var args = OS.GetCmdlineArgs();
        if (args.Contains("Server"))
        {
            return false;
        }
        return true;
    }

    /// <summary>
    /// Sends a RemoteEvent from the local client to the server.
    /// </summary>
    /// <typeparam name="T">The RemoteEvent type.</typeparam>
    /// <param name="data">
    /// Arguments used to construct the RemoteEvent.
    /// </param>
    /// 
    public static void SendToServer<T>(params object[] data)
        where T : RemoteEvent, new()
    {
        if (IsClient())
        {
            T remoteEvent = RemoteEvent.Create<T>(data);
            Client.Connection.Broadcast(0, remoteEvent.Encode(), remoteEvent.Flag);
        }
    }

    /// <summary>
    /// Sends a RemoteEvent from the server to a specific client.
    /// </summary>
    /// <typeparam name="T">The RemoteEvent type.</typeparam>
    /// <param name="peerId">Target peer ID.</param>
    /// <param name="data">
    /// Arguments used to construct the RemoteEvent.
    /// </param>
    /// 
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

    /// <summary>
    /// Sends a RemoteEvent from the server to all connected clients.
    /// </summary>
    /// <typeparam name="T">The RemoteEvent type.</typeparam>
    /// <param name="data">
    /// Arguments used to construct the RemoteEvent.
    /// </param>
    /// 
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

    /// <summary>
    /// Decodes incoming packets and fires their RemoteEvents.
    /// </summary>
    /// <param name="evnt">Packet reception event.</param>
    /// 
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

    /// <summary>
    /// Automatically discovers and registers all non-abstract RemoteEvent types.
    /// </summary>
    /// 
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
