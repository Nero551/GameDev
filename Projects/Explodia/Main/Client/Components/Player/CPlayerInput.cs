using Godot;
using System;
using System.Collections.Generic;

public partial class CPlayerInput : Component
{
    private Dictionary<string, double> InputBuffers = new();
    private IInputible inputible;

    const double bufferTime = 0.15;
    //TODO Input buffer and custom input functions to help centralize input use even more.

    protected override void OnInit()
    {
        inputible = Owner as IInputible;
    }

    public void PlayerInput(double delta)
    {

        if (World.DebugCam.Current)
        {
            return;
        }
        if (Input.IsActionPressed("M1"))
        {
            inputible.Character.Ccombat.M1();
        }
        if (Input.IsActionPressed("M2"))
        {
            inputible.Character.Ccombat.M2();
        }

        if (Input.IsActionJustPressed("ExitGame"))
        {
            Input.MouseMode = Input.MouseModeEnum.Visible;
        }

        if (Input.IsActionJustPressed("Sprint"))
        {
            if (inputible.Character.Cstates.CheckState("Sprinting"))
            {
                inputible.Character.Cstates.RemoveState("Sprinting");
            }
            else
            {
                inputible.Character.Cstates.AddState("Sprinting");
            }
        }
        inputible.Character.MoveDirection = Input.GetVector("Left", "Right", "Back", "Forward");
    }
}
