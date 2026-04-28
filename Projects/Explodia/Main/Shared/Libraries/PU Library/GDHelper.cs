using Godot;
using System;
using System.Security.Cryptography.X509Certificates;

public partial class PULib
{
    //? Returns Time in seconds.
    public static double CurrentSTime()
    {
        return Time.GetTicksMsec() / 1000;
    }


    //? Removes the node after the specified lifetime has passed.
    public static async void ScheduleRemoval(Node node, float lifetime)
    {
        await node.ToSignal(node.GetTree().CreateTimer(lifetime), "timeout");

        if (GodotObject.IsInstanceValid(node))
            node.QueueFree();
    }
}
