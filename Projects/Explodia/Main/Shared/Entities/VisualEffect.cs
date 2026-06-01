using System;
using System.Threading.Tasks;
using Godot;

[Tool, GlobalClass]
public partial class VisualEffect : Node3D
{
    [Export] public bool Emit { get; set { field = false; Play(); } } = false;
    [Export] public bool LoopPlay { get; set { field = value; PlayWithDelayAsync(); } } = false;
    [Export] public string Animation;
    [Export] public float Delay = 0.1f;

    private ComponentHost componentHost;
    private CAnimations cAnimations;

    public override void _Ready()
    {
        LoopPlay = false;
        componentHost = ComponentHost.Create(this);
    }

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
        if (Animation != "" && GetNodeOrNull<AnimationPlayer>("AnimationPlayer") != null)
        {
            cAnimations = componentHost.AddComponent<CAnimations>();
            cAnimations.PlayAnim(Animation, 1);
        }
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
            Emit = true;
            await ToSignal(GetTree().CreateTimer(Delay), SceneTreeTimer.SignalName.Timeout);
        }
    }
}

