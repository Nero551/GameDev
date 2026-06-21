using System;
using Godot;

public partial class Enemy : Character
{
    private CAI cAI;
    private CBrain cBrain;

    public override void _Ready()
    {
        base._Ready();
        cAI = componentHost.AddComponent<CAI>();
        cBrain = componentHost.AddComponent<CBrain>();
    }

    public override void _Process(double delta)
    {
        cBrain.Think();
        cAI.StateUpdater(delta);
        base._Process(delta);
    }

    public override void _PhysicsProcess(double delta)
    {
        base._PhysicsProcess(delta);
    }
}
