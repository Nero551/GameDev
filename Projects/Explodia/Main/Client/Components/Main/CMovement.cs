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
        MovementVelocity = Entity.GetInterface<IVelocity>().Velocity;

        if (!Entity.GetInterface<IIsOnFloor>().IsOnFloor())
        {
            MovementVelocity += Entity.GetInterface<IGetGravity>().GetGravity() * (float)delta;
            Force += Entity.GetInterface<IGetGravity>().GetGravity() * (float)delta;
        }
        if (MovementVelocity != Vector3.Zero)
        {
            MovementVelocity.X = Mathf.MoveToward(MovementVelocity.X, 0, Speed);
            MovementVelocity.Z = Mathf.MoveToward(MovementVelocity.Z, 0, Speed);
        }

        if (Force != Vector3.Zero)
        {
            Force.X = Mathf.MoveToward(Force.X, 0, Speed);
            Force.Z = Mathf.MoveToward(Force.Z, 0, Speed);
        }
    }

    public void Jump()
    {
        if (Entity.GetInterface<IIsOnFloor>().IsOnFloor())
        {
            MovementVelocity.Y = JumpPower;
        }
    }

    public void Move(double delta)
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

        Vector3 targetDir = (
        Entity.GetInterface<IGlobalPosition>().GlobalPosition + MovementVelocity -
        Entity.Owner.GetNode<Node3D>("__Animation Dummy_Armature").GlobalPosition);

        targetDir.Y = 0;
        targetDir.Normalized();

        if (targetDir != Vector3.Zero)
        {
            Basis target = Basis.LookingAt(targetDir, Vector3.Up);

            Entity.Owner.GetNode<Node3D>("__Animation Dummy_Armature").Basis =
             Entity.Owner.GetNode<Node3D>("__Animation Dummy_Armature").Basis.Slerp(target, 8f * (float)delta);
        }
    }

    public void ApplyVelocity()
    {
        Entity.GetInterface<IVelocity>().Velocity = MovementVelocity + Force;
        Entity.GetInterface<IMoveAndSlide>().MoveAndSlide();
    }
}

