using Godot;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

public partial class Player : Character
{

    //TODO Make Combat System.
    public override void _Ready()
    {
        PULib.CallInitMethods(this);
    }
    public override void _Input(InputEvent @event)
    {
        ZoomCamera();
        RotateCamera(@event);
        Test();
        BasicAttack();
    }

    public override void _Process(double delta)
    {
        UpdateStatesDuration(delta);
        HandleStates(delta);
    }
    public override void _PhysicsProcess(double delta)
    {
        MovementPhysics(delta);
    }
}
