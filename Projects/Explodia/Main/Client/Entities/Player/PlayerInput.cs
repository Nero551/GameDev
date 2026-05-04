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
            Character.CCombat.M1();
        }
        if (Input.IsActionPressed("M2"))
        {
            Character.CCombat.M2();
        }

        if (Input.IsActionJustPressed("ExitGame"))
        {
            Input.MouseMode = Input.MouseModeEnum.Visible;
        }

        if (Input.IsActionJustPressed("Sprint"))
        {
            if (Character.CStates.CheckState("Sprinting"))
            {
                Character.CStates.RemoveState("Sprinting");
            }
            else
            {
                Character.CStates.AddState("Sprinting");
            }
        }
        Character.MoveDirection = Input.GetVector("Left", "Right", "Back", "Forward");
    }
}
