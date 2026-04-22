using Godot;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

public partial class Player : Character
{
    public override void _Ready()
    {
        PULib.CallInitMethods(this);
    }

    public override void _Input(InputEvent @event)
    {
        ZoomCamera();
        RotateCamera(@event);
        Test(@event);
    }
    public override void _Process(double delta)
    {
        UpdateStates(delta);
    }
    public override void _PhysicsProcess(double delta)
    {
        MovementPhysics(delta);
    }
}
