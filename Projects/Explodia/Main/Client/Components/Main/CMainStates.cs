using System;
using Godot;

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
            Vector3 horizontal = new Vector3(Entity.GetInterface<IVelocity>().Velocity.X, 0, Entity.GetInterface<IVelocity>().Velocity.Z);
            if (horizontal.LengthSquared() > 0.01f)
                MainState = MainStates.Moving;
            else
                MainState = MainStates.Idle;
        }
        // GD.Print(MainState);
    }
}
