using Godot;
using System;

public partial class CompMainStates : Component
{
    private IMainStatable mainStatable;
    private Character character;

    public enum MainStates
    {
        Jumping,
        Moving,
        Falling,
        Idle,
    }

    [Export] public MainStates MainState;

    protected override void OnInit()
    {
        mainStatable = Owner as IMainStatable;
        character = Owner as Character;
    }

    public void HandleMainStates()
    {
        if (!mainStatable.IsOnFloor())
        {
            GD.Print("Nice");
            if (mainStatable.Velocity.Y > 0)
                MainState = MainStates.Jumping;
            else
                MainState = MainStates.Falling;
        }
        else
        {
            if (Entity.GetComponent<CompMovement>().IsMoving())
                MainState = MainStates.Moving;
            else
                MainState = MainStates.Idle;
        }
        GD.Print(MainState);
    }
}
