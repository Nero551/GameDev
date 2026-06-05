using System;
using System.Linq;
using Godot;

public partial class NetworkingService : Node
{
    public static bool IsServer()
    {
        var args = OS.GetCmdlineArgs();
        if (args.Contains("--server"))
        {
            return true;
        }
        return false;
    }

    public static bool IsClient()
    {
        var args = OS.GetCmdlineArgs();
        if (args.Contains("--server"))
        {
            return false;
        }
        return true;
    }

    public void SendToServer(string rpcName, params Variant[] args)
    {
        if (IsClient())
        {
            RpcId(1, rpcName, args);
        }
    }
    public void SendToAllClients()
    {

    }
}
