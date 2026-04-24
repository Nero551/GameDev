using Godot;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

public partial class Player : Character
{
    public override void _Ready()
    {
        base._Ready();
        InitCamera();
    }
    public override void _Input(InputEvent @event)
    {
        PlayerInput();
        ZoomCamera();
        RotateCamera(@event);
    }

    public override void _PhysicsProcess(double delta)
    {
        MovementPhysics(delta);
    }
}
