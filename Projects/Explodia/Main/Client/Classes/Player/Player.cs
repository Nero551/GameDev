using Godot;
using System;

public partial class Player : Character
{
    public override void _Ready()
    {
        base._Ready();
        InitCamera();
    }
    public override void _Input(InputEvent @event)
    {
        RotateCamera(@event);
    }

    public override void _PhysicsProcess(double delta)
    {
        PlayerInput(delta);
        ZoomCamera();
        MovementPhysics(delta);
    }
}
