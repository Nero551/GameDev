using Godot;
using System;
using System.Collections.Generic;

public partial class Player
{
    private Dictionary<string, double> InputBuffers = new();
    const double bufferTime = 0.15;
    //TODO Input buffer and custom input functions to help centralize input use even more.

    public void PlayerInput(double delta)
    {
        if (Input.IsActionPressed("M1"))
        {
            M1();
        }
        if (Input.IsActionPressed("M2"))
        {
            M2();
        }

        if (Input.IsActionJustPressed("ExitGame"))
        {
            Input.MouseMode = Input.MouseModeEnum.Visible;
        }

        if (Input.IsActionJustPressed("Sprint"))
        {
            if (CheckState("Sprinting"))
            {
                RemoveState("Sprinting");
            }
            else
            {
                AddState("Sprinting");
            }
        }
        MoveDirection = Input.GetVector("Left", "Right", "Back", "Forward");

    }
}
