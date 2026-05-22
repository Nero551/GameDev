using System;
using Godot;

public class VisualService : Service
{
    public static Node3D Spawn(string filepath, Node parent, Vector3 pos, float lifeTime = 5f)
    {
        PackedScene scene = GD.Load<PackedScene>($"res://Main/{filepath}");
        if (scene == null)
        {
            return null;
        }

        Node3D vfx = scene.Instantiate<Node3D>();
        parent.AddChild(vfx);
        vfx.GlobalPosition = pos;

        Play(vfx);
        DestroyAsync(vfx, lifeTime);
        return vfx;
    }

    private static void Play(Node node)
    {
        //* Recursive searching.
        if (node is GpuParticles3D particle)
        {
            particle.Restart();
            particle.Emitting = true;
        }
        foreach (Node child in node.GetChildren())
        {
            Play(child);
        }
    }

    private static async void DestroyAsync(Node3D vfx, float lifeTime)
    {
        await vfx.ToSignal(vfx.GetTree().CreateTimer(lifeTime), SceneTreeTimer.SignalName.Timeout);
        vfx.QueueFree();
    }
}
