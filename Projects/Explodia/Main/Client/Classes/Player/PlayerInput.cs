using Godot;
using System;

public partial class Player
{
    public void PlayerInput()
    {
        if (Input.IsActionPressed("Basic Attack"))
        {
            BasicAttack();
        }

        if (Input.IsActionJustPressed("ExitGame"))
        {
            Input.MouseMode = Input.MouseModeEnum.Visible;
        }

    }
}
