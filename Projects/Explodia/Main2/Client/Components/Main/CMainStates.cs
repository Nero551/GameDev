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
        if (!ComponentHost.GetInterface<IIsOnFloor>().IsOnFloor())
        {
            if (ComponentHost.GetInterface<IVelocity>().Velocity.Y > 0)
                MainState = MainStates.Jumping;
            else
                MainState = MainStates.Falling;
        }
        else
        {
            Vector3 horizontal = new Vector3(ComponentHost.GetInterface<IVelocity>().Velocity.X, 0, ComponentHost.GetInterface<IVelocity>().Velocity.Z);
            if (horizontal.LengthSquared() > 0.01f)
                MainState = MainStates.Moving;
            else
                MainState = MainStates.Idle;
        }
    }
}
