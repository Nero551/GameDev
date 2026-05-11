using Godot;
using System;
using System.Collections.Generic;

public partial class CPlayerInput : Component
{
    private Dictionary<string, double> InputBuffers = new();
    private ECharacter character;

    const double bufferTime = 0.15;
    //TODO Input buffer and custom input functions to help centralize input use even more.

    protected override void OnInit()
    {
        character = Entity.GetComponent<CCharacter>().Character;
    }

    public void PlayerInput(double delta)
    {

        if (World.DebugCam.Current)
        {
            return;
        }
        if (Input.IsActionPressed("M1"))
        {
            character.Ccombat.M1();
        }
        if (Input.IsActionPressed("M2"))
        {
            character.Ccombat.M2();
        }

        if (Input.IsActionJustPressed("ExitGame"))
        {
            Input.MouseMode = Input.MouseModeEnum.Visible;
        }

        if (Input.IsActionJustPressed("Jump"))
        {
            character.Cmovement.Jump();
        }

        if (Input.IsActionJustPressed("Sprint"))
        {
            if (character.Cstates.CheckState("Sprinting"))
            {
                character.Cstates.RemoveState("Sprinting");
            }
            else
            {
                character.Cstates.AddState("Sprinting");
            }
        }
        character.Cmovement.MoveDirection = Input.GetVector("Left", "Right", "Back", "Forward");
        GD.Print(character.Cmovement.MoveDirection);
    }
}
