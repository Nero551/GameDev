using Godot;
using System;

public partial class CMovement : Component
{
    public Vector3 velocity;
    public float Speed;
    public float JumpPower;
    public Vector2 MoveDirection = Vector2.Zero;
    public bool IsMoving()
    {
        Vector3 horizontal = new Vector3(
            Entity.GetInterface<IVelocity>().Velocity.X, 0, Entity.GetInterface<IVelocity>().Velocity.Z
        );
        return horizontal.LengthSquared() > 0.01f;
    }

    /*
    TODO
    am gonna merge player movement with this. idea is , this script will have a velocity variable, the main gravity , move and jump methods.
    TODO- as for camera adjustments. camera component will just modify the velocity variable
    */
}
