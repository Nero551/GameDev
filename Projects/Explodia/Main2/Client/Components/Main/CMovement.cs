using System;
using Godot;

public partial class CMovement : Component
{
    public Vector3 MovementVelocity;
    public Vector3 Force;

    public float Speed;
    public float JumpPower;
    public Vector2 MoveDirection = Vector2.Zero;

    public void Gravity(double delta)
    {
        if (!ComponentHost.GetInterface<IIsOnFloor>().IsOnFloor())
        {
            MovementVelocity += ComponentHost.GetInterface<IGetGravity>().GetGravity() * (float)delta * 1.5f;
        }
    }

    public void Jump()
    {
        if (ComponentHost.GetInterface<IIsOnFloor>().IsOnFloor())
        {
            MovementVelocity.Y = JumpPower;
        }
    }

    public void Move()
    {
        MovementVelocity = new Vector3(MoveDirection.X + MovementVelocity.X, MovementVelocity.Y, MoveDirection.Y + MovementVelocity.Z);
        if (MovementVelocity != Vector3.Zero)
        {
            MovementVelocity.X *= Speed;
            MovementVelocity.Z *= Speed;
        }
    }

    public void ApplyBodyRotation(double delta)
    {
        Vector3 targetDir = MovementVelocity;

        targetDir.Y = 0;
        targetDir = targetDir.Normalized();

        if (targetDir != Vector3.Zero)
        {
            Basis target = Basis.LookingAt(targetDir, Vector3.Up);
            ComponentHost.GetInterface<ITransform3D>().Basis =
                ComponentHost.GetInterface<ITransform3D>().Basis.Orthonormalized().Slerp(target, 8f * (float)delta);
        }
    }

    private void Decay()
    {
        if (MovementVelocity != Vector3.Zero)
        {
            MovementVelocity.X = Mathf.MoveToward(MovementVelocity.X, 0, Speed);
            MovementVelocity.Z = Mathf.MoveToward(MovementVelocity.Z, 0, Speed);
        }

        if (Force != Vector3.Zero)
        {
            Force.X = Mathf.MoveToward(Force.X, 0, 2);
            Force.Z = Mathf.MoveToward(Force.Z, 0, 2);
        }
    }

    public void ApplyVelocity()
    {
        ComponentHost.GetInterface<IVelocity>().Velocity = MovementVelocity + Force;
        ComponentHost.GetInterface<IMoveAndSlide>().MoveAndSlide();
        Decay();
    }
}

