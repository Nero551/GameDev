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
        //TODO Function to auto call all functions with "Init" in them
        //TODO maybe even same thing with other functions like "Update" prefix for all _Process functions
        InitCamera();
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


    // Called every frame. 'delta' is the elapsed time since the previous frame.
    // public override void _Process(double delta)
    // {
    // 	if (Input.IsActionJustPressed("ExitGame"))
    // 	{
    // 		Input.MouseMode = Input.MouseModeEnum.Visible;
    // 	}
    // }
}
