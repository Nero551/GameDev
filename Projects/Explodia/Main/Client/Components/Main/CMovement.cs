using Godot;
using System;

public partial class CMovement : Component
{
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
}
