using System;
using Godot;

public partial class CMovement : Component
{
    public Vector3 MovementVelocity;
    public Vector3 Force;
    public float Speed;
    public float JumpPower;
    public Vector2 MoveDirection = Vector2.Zero;

    public void Move()
    {
        MovementVelocity.X = MoveDirection.X + MovementVelocity.X;
        MovementVelocity.Z = MoveDirection.Y + MovementVelocity.Z;

        if (MovementVelocity != Vector3.Zero)
        {
            MovementVelocity.X *= Speed;
            MovementVelocity.Z *= Speed;
        }
        Entity.GetInterface<IVelocity>().Velocity = MovementVelocity;
        Entity.GetInterface<IMoveAndSlide>().MoveAndSlide();
    }

}

