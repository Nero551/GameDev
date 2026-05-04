using Godot;
using System;

public partial class CMainStates : Component
{
    private IMainStatable IMainStatable;
    private ECharacter character;

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
        IMainStatable = Owner as IMainStatable;
        character = Owner as ECharacter;

    }

    public void HandleMainStates()
    {
        if (!IMainStatable.IsOnFloor())
        {
            if (IMainStatable.Velocity.Y > 0)
                MainState = MainStates.Jumping;
            else
                MainState = MainStates.Falling;
        }
        else
        {
            if (Entity.GetComponent<CMovement>().IsMoving())
                MainState = MainStates.Moving;
            else
                MainState = MainStates.Idle;
        }
        GD.Print(MainState);
    }
}
