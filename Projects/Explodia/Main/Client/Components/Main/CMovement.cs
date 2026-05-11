using Godot;
using System;

public partial class CMovement : Component
{
    public Vector3 velocity;
    public float Speed;
    public float JumpPower;
    public Vector2 MoveDirection = Vector2.Zero;

    public void Gravity(double delta)
    {
        velocity = Entity.GetInterface<IVelocity>().Velocity;

        if (!Entity.GetInterface<IIsOnFloor>().IsOnFloor())
        {
            velocity += Entity.GetInterface<IGetGravity>().GetGravity() * (float)delta;
        }
        if (velocity != Vector3.Zero)
        {
            velocity.X = Mathf.MoveToward(Entity.GetInterface<IVelocity>().Velocity.X, 0, Speed);
            velocity.Z = Mathf.MoveToward(Entity.GetInterface<IVelocity>().Velocity.Z, 0, Speed);
        }
    }

    public void Jump()
    {
        if (Entity.GetInterface<IIsOnFloor>().IsOnFloor())
        {
            velocity.Y = JumpPower;
        }
    }

    public void Move(double delta)
    {
        velocity = new Vector3(MoveDirection.X, velocity.Y, MoveDirection.Y);
        if (velocity != Vector3.Zero)
        {
            velocity.X *= Speed;
            velocity.Z *= Speed;
        }
    }

    public void ApplyBodyRotation(double delta)
    {
        Vector3 targetDir = (
        Entity.GetInterface<IGlobalPosition>().GlobalPosition + velocity -
        Entity.Owner.GetNode<Node3D>("__Animation Dummy_Armature").GlobalPosition).Normalized();

        GD.Print(targetDir);
        Basis target = Basis.LookingAt(targetDir, Vector3.Up);

        Entity.Owner.GetNode<Node3D>("__Animation Dummy_Armature").Basis =
         Entity.Owner.GetNode<Node3D>("__Animation Dummy_Armature").Basis.Slerp(target, 8f * (float)delta);
    }

    public void ApplyVelocity()
    {
        GD.Print(velocity);
        Entity.GetInterface<IVelocity>().Velocity = velocity;
        Entity.GetInterface<IMoveAndSlide>().MoveAndSlide();
    }

    /*
TODO
am gonna merge player movement with this. idea is , this script will have a velocity variable, the main gravity , move and jump methods.
TODO- as for camera adjustments. camera component will just modify the velocity variable
*/
}


