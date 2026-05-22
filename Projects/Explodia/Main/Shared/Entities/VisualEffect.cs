using System;
using Godot;

[GlobalClass]
public partial class VisualEffect : Node3D
{
    [Export] public float Duration = 10f;

    public static VisualEffect Spawn(string filepath, Node parent, Vector3 pos)
    {
        PackedScene scene = GD.Load<PackedScene>($"res://Main/{filepath}");
        if (scene == null)
        {
            return null;
        }

        VisualEffect vfx = scene.Instantiate<VisualEffect>();
        parent.AddChild(vfx);
        vfx.GlobalPosition = pos;
        return vfx;
    }

    public override void _Ready()
    {
        Play();
        DestroyAsync();
    }

    public void Play()
    {
        foreach (Node child in GetChildren())
        {
            if (child is GpuParticles3D particle)
            {
                particle.Restart();
                particle.Emitting = true;
            }
        }
    }
    public async void DestroyAsync()
    {
        await ToSignal(GetTree().CreateTimer(Duration), SceneTreeTimer.SignalName.Timeout);
        QueueFree();
    }
}
