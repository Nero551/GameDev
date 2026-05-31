using System;
using System.Threading.Tasks;
using Godot;

[Tool, GlobalClass]
public partial class VisualEffect : Node3D
{
    [Export] public bool Emit { get; set { field = false; Play(); } } = false;
    [Export] public bool LoopPlay { get; set { field = value; PlayWithDelayAsync(); } } = false;
    [Export] public float Delay = 0.1f;

    public static VisualEffect Spawn(string filepath, Node parent, Vector3? pos = null, float lifeTime = 5f)
    {
        PackedScene scene = GD.Load<PackedScene>($"res://Main/{filepath}");
        if (scene == null)
        {
            return null;
        }

        VisualEffect vfx = scene.Instantiate<VisualEffect>();
        parent.AddChild(vfx);
        if (pos is Vector3 p)
        {
            vfx.GlobalPosition = p;
        }

        vfx.Emit = true;
        vfx.DestroyAsync(lifeTime);
        return vfx;
    }

    public void Play()
    {
        RecursivePlay(this);
    }

    public void Stop()
    {
        RecursiveStop(this);
    }

    private void RecursivePlay(Node node)
    {
        if (node is GpuParticles3D particle)
        {
            particle.Restart();
            particle.Emitting = true;
        }
        foreach (Node child in node.GetChildren())
        {
            RecursivePlay(child);
        }
    }

    private void RecursiveStop(Node node)
    {
        if (node is GpuParticles3D particle)
        {
            particle.Emitting = false;
        }
        foreach (Node child in node.GetChildren())
        {
            RecursivePlay(child);
        }
    }

    private async void DestroyAsync(float lifeTime)
    {
        await ToSignal(GetTree().CreateTimer(lifeTime), SceneTreeTimer.SignalName.Timeout);
        QueueFree();
    }

    private async void PlayWithDelayAsync()
    {
        while (LoopPlay == true)
        {
            Play();
            await ToSignal(GetTree().CreateTimer(Delay), SceneTreeTimer.SignalName.Timeout);
        }
    }
}

