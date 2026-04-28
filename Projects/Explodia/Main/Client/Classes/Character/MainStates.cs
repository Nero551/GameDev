using Godot;
using System;
using System.Security.Cryptography.X509Certificates;

public partial class Character
{
    public enum MainStates
    {
        Jumping,
        Moving,
        Falling,
        Idle,
    }
    public void UpdateMainStates()
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
            if (Velocity.Length() > 0.1f)
                MainState = MainStates.Moving;
            else
                MainState = MainStates.Idle;
        }
    }
}
