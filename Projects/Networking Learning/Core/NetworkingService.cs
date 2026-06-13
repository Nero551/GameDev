using System;
using System.Linq;
using Godot;

public static class NetworkingService
{
    public enum NetworkCall
    {

    }
    //TODO- i have decided i will make custom packet sender and reciever instead of using the godot RPC system.
    /*
    the core of this is , u convert argument into bytes , u send them with ENet , u unconvert them back into data
    */
    //* Reason for this is: RPC depends on nodes , my framework doesnot depend on nodes.
    //TODO- make public enum for creating network calls instead of using strings. more safe.
    //TODO- channels enum for like "reliable" and "unreliable"
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

    public static void SendToServer(NetworkCall call, params object[] args)
    {
        if (!IsClient())
        {
            return;
        }   
    }

    public static void SendToClient(NetworkCall call, params object[] args)
    {
        if (!IsServer())
        {
            return;
        }
    }
}
