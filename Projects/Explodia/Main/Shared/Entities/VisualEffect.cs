using System;
using System.Threading.Tasks;
using Godot;

[Tool, GlobalClass]
public partial class VisualEffect : Node3D
{
    //TODO-  later i will need a VisualsService to manage VFX and pooling and stuff.

    [Export] public bool Emit { get; set { field = false; Play(); } } = false;
    [Export] public bool LoopPlay = false;
    [Export] public string Animation;
    [Export] public float Delay = 0.1f;

    private ComponentHost componentHost;
    // private CAnimations cAnimations;

    public override void _Ready()
    {
        SetProcess(true);
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
        //Animation
        // if (Animation != "" && GetNodeOrNull<AnimationPlayer>("AnimationPlayer") != null)
        // {
        //     cAnimations = componentHost.AddComponent<CAnimations>();
        //     cAnimations.PlayAnim(Animation, 1);
        // }

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
            RecursiveStop(child);
        }
    }

    private async void DestroyAsync(float lifeTime)
    {
        await ToSignal(GetTree().CreateTimer(lifeTime), SceneTreeTimer.SignalName.Timeout);
        QueueFree();
    }

    double elapsed = 0;
    public override void _Process(double delta)
    {
        if (LoopPlay)
        {
            elapsed += delta;
            if (elapsed >= Delay)
            {
                elapsed = 0; Emit = true;
            }
        }
        else
        {
            elapsed = 0;
        }
    }
}

