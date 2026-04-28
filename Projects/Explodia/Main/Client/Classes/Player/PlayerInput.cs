using Godot;
using System;

public partial class Player
{
    public void PlayerInput()
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

        if (Input.IsActionJustPressed("Sprint")){
            if (CheckState("Sprinting"))
            {
                RemoveState("Sprinting");
            }
            else
            {
                AddState("Sprinting");
            }
        }

    }
}
