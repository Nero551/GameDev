using Godot;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

public partial class Player : Character
{
    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        InitCamera();
    }

    public override void _Input(InputEvent @event)
    {
        RotateCamera(@event);
    }
    public override void _Process(double delta)
    {
        Test(delta);
    }
    public override void _PhysicsProcess(double delta)
    {
        MovementPhysics(delta);
    }


    // Called every frame. 'delta' is the elapsed time since the previous frame.
    // public override void _Process(double delta)
    // {
    // 	if (Input.IsActionJustPressed("ExitGame"))
    // 	{
    // 		Input.MouseMode = Input.MouseModeEnum.Visible;
    // 	}
    // }
}
