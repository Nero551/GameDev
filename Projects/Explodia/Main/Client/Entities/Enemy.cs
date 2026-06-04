using System;
using Godot;

public partial class Enemy : Character
{
    private CAI cAI;

    public override void _Ready()
    {
        base._Ready();
        cAI = componentHost.AddComponent<CAI>();
    }

    public override void _Process(double delta)
    {
        base._Process(delta);
    }

    public override void _PhysicsProcess(double delta)
    {
        base._PhysicsProcess(delta);
        cAI.StateUpdater(delta);
        GD.Print(cMainStates.MainState);
    }
}
