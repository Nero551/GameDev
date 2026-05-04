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
        if (Input.IsActionJustPressed("SwitchCam"))
        {
            SwitchCam();
        }

        if (World.DebugCam.Current)
        {
            return;
        }
        if (Input.IsActionPressed("M1"))
        {
            Character.compCombat.M1();
        }
        if (Input.IsActionPressed("M2"))
        {
            Character.compCombat.M2();
        }

        if (Input.IsActionJustPressed("ExitGame"))
        {
            Input.MouseMode = Input.MouseModeEnum.Visible;
        }

        if (Input.IsActionJustPressed("Sprint"))
        {
            if (Character.compStates.CheckState("Sprinting"))
            {
                Character.compStates.RemoveState("Sprinting");
            }
            else
            {
                Character.compStates.AddState("Sprinting");
            }
        }
        Character.MoveDirection = Input.GetVector("Left", "Right", "Back", "Forward");
    }
}
