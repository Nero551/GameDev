using Godot;
using System;

public partial class Character
{
    public enum MainStates
    {
        Jumping,
        Moving,
        Falling,
        Idle,
    }
    public void HandleMainStates()
    {
        if (!IsOnFloor())
        {
            if (Velocity.Y > 0)
                MainState = MainStates.Jumping;
            else
                MainState = MainStates.Falling;
        }
        else
        {
            if (IsMoving())
                MainState = MainStates.Moving;
            else
                MainState = MainStates.Idle;
        }
    }
}
