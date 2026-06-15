using System;
using System.Collections.Generic;
using System.Linq;
using Godot;
using Godot.NativeInterop;

public static class NetworkingService
{
    public enum NetworkCall
    {

    }
    //TODO- i have decided i will make custom packet sender and reciever instead of using the godot RPC system.
    /*
    the core of this is , u convert data into bytes , u send them with ENet , u unconvert them back into data
    */
    //* Reason for this is: RPC depends on nodes , my framework doesnot depend on nodes.
    //TODO- make public enum for creating network calls instead of using strings. more safe.
    //TODO- channels enum for like "reliable" and "unreliable"

    //* Server Signals
    [Signal] public delegate void OnClientConnectedEventHandler(int clientId);
    [Signal] public delegate void OnClientDisconnectedEventHandler(int clientId);
    [Signal] public delegate void OnServerPacketEventHandler(int clientId, godot_packed_byte_array data);

    //* Client Signals
    [Signal] public delegate void OnConnectedToServerEventHandler();
    [Signal] public delegate void OnDisconnectedFromServerEventHandler();
    [Signal] public delegate void OnClientPacketEventHandler(godot_packed_byte_array data);

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

    /*
        * No need for client class since the player class IS the client.
        Here and the function down there. there should be the packett send methods.
        i will rarely interact with the actual packet class.
        how to create packet:
        1-create class and inherit packet class.
        2-override send and recieve methods to have custom encoding and decoding.
    */

    public static void SendToServer<T>(params object[] data) where T : Packet, new()
    {
        
        //TODO- send the id of the player who sent tthis to the server.
        // EventService.Invoke(EventService.Event.OnClientConnected, );
        if (IsClient())
        {
            T packet = new();
            packet.Send(1, data);
        }
    }

    public static void SendToClient<T>(int id, params object[] data) where T : Packet, new()
    {
        if (IsServer())
        {
            T packet = new();
            packet.Send(id, data);
        }
    }

    public static void SendToAllClients<T>(params object[] data) where T : Packet, new()
    {
        if (IsServer())
        {
            foreach (KeyValuePair<long, Player> pair in Server.Players)
            {
                T packet = new();
                packet.Send(pair.Value.UserId, data);
            }
        }
    }
}
