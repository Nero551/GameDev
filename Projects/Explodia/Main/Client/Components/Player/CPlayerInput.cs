using Godot;
using System;
using System.Collections.Generic;

public partial class CPlayerInput : Component
{
    private Dictionary<string, double> InputBuffers = new();
    private Character character;

    const double bufferTime = 0.15;
    //TODO Input buffer, and custom input functions to help centralize input use even more.

    protected override void OnInit()
    {
        character = ComponentHost.GetComponent<CCharacter>().Character;
    }

    public void PlayerInput(double delta)
    {
        if (Input.IsActionPressed("M1"))
        {
            character.cCombat.M1();
        }
        if (Input.IsActionPressed("M2"))
        {
            character.cCombat.M2();
        }

        if (Input.IsActionJustPressed("ExitGame"))
        {
            Input.MouseMode = Input.MouseModeEnum.Visible;
        }

        if (Input.IsActionJustPressed("Jump"))
        {
            character.cMovement.Jump();
        }

        if (Input.IsActionJustPressed("Sprint"))
        {
            if (character.cStates.CheckState("Sprinting"))
            {
                character.cStates.RemoveState("Sprinting");
            }
            else
            {
                character.cStates.AddState("Sprinting");
            }
        }
        character.cMovement.MoveDirection = Input.GetVector("Left", "Right", "Back", "Forward");
    }
}
