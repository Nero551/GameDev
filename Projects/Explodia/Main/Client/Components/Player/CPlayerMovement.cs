using Godot;
using System;

public partial class CPlayerMovement : Component
{
    private IPlayerMovable playerMovable;

    protected override void OnInit()
    {
        playerMovable = Owner as IPlayerMovable;
    }

    public void MovementPhysics(double delta)
    {
        Vector3 velocity = playerMovable.Character.Velocity;

        if (!playerMovable.Character.IsOnFloor())
        {
            velocity += playerMovable.Character.GetGravity() * (float)delta;
        }

        if (Input.IsActionJustPressed("Jump") && playerMovable.Character.IsOnFloor())
        {
            velocity.Y = playerMovable.Character.JumpPower;
        }

        Vector3 forward = -playerMovable.SpringArm.GlobalTransform.Basis.Z;
        Vector3 right = playerMovable.SpringArm.GlobalTransform.Basis.X;
        forward.Y = 0;
        right.Y = 0;
        forward = forward.Normalized();
        right = right.Normalized();

        Vector3 direction =
        (right * playerMovable.Character.MoveDirection.X + forward * playerMovable.Character.MoveDirection.Y
        ).Normalized();

        if (direction != Vector3.Zero)
        {
            velocity.X = direction.X * playerMovable.Character.Speed;
            velocity.Z = direction.Z * playerMovable.Character.Speed;

            //? Smooths character rotation 
            // I dont understand how this works but it works
            Vector3 targetDir = (playerMovable.Character.GlobalPosition + direction - playerMovable.Character.Rig.GlobalPosition).Normalized();
            Basis target = Basis.LookingAt(targetDir, Vector3.Up);

            playerMovable.Character.Rig.Basis = playerMovable.Character.Rig.Basis.Slerp(target, 8f * (float)delta);
        }
        else
        {
            velocity.X = Mathf.MoveToward(playerMovable.Character.Velocity.X, 0, playerMovable.Character.Speed);
            velocity.Z = Mathf.MoveToward(playerMovable.Character.Velocity.Z, 0, playerMovable.Character.Speed);
        }

        playerMovable.Character.Velocity = velocity;
        playerMovable.Character.MoveAndSlide();
    }
}
