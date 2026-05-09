using Godot;
using System;

public partial class CMainStates : Component
{
    public enum MainStates
    {
        Jumping,
        Moving,
        Falling,
        Idle,
    }

    public MainStates MainState;

    public void HandleMainStates()
    {
        if (!Entity.GetInterface<IIsOnFloor>().IsOnFloor())
        {
            if (Entity.GetInterface<IVelocity>().Velocity.Y > 0)
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
