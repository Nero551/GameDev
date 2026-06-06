using System;
using System.Linq;
using Godot;

public partial class NetworkingService : Node
{

    //TODO- i have decided i will make custom packet sender and reciever instead of using the godot RPC system.
    /*
    the core of this is , u convert argument into bytes , u send them with ENet , u unconvert them back into data
    */
    //* Reason for this is: RPC depends on nodes , my framework doesnot depend on nodes.
    //TODO- make public enum for creating network calls instead of using strings. more safe.
    public static NetworkingService Instance;
    public override void _Ready()
    {
        base._Ready();
        Instance = this;
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

    public void SendToServer(string rpcName, params Variant[] args)
    {
        if (IsClient())
        {
            RpcId(1, nameof(rpcName), args);
        }
    }
    public void SendToAllClients()
    {

    }
}
