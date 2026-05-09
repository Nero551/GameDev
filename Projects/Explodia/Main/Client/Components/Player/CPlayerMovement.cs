using Godot;
using System;

public partial class CPlayerMovement : Component
{
    private ECharacter character;

    protected override void OnInit()
    {
        character = Entity.GetComponent<CCharacter>().Character;
    }
    public void MovementPhysics(double delta)
    {
        Vector3 velocity = character.Velocity;

        if (!character.IsOnFloor())
        {
            velocity += character.GetGravity() * (float)delta;
        }

        if (Input.IsActionJustPressed("Jump") && character.IsOnFloor())
        {
            velocity.Y = character.Entity.GetComponent<CMovement>().JumpPower;
        }

        Vector3 forward = -Entity.GetComponent<CCamera>().SpringArm.GlobalTransform.Basis.Z;
        Vector3 right = Entity.GetComponent<CCamera>().SpringArm.GlobalTransform.Basis.X;
        forward.Y = 0;
        right.Y = 0;
        forward = forward.Normalized();
        right = right.Normalized();

        Vector3 direction =
        (right * character.Cmovement.MoveDirection.X +
         forward * character.Cmovement.MoveDirection.Y
        ).Normalized();

        if (direction != Vector3.Zero)
        {
            velocity.X = direction.X * character.Cmovement.Speed;
            velocity.Z = direction.Z * character.Cmovement.Speed;

            //? Smooths character rotation 
            // I dont understand how this works but it works
            Vector3 targetDir = (
                character.GlobalPosition + direction -
                Entity.GetComponent<CCharacter>().Character.Rig.GlobalPosition
                ).Normalized();
            Basis target = Basis.LookingAt(targetDir, Vector3.Up);

            character.Rig.Basis = Entity.GetComponent<CCharacter>().Character.Rig.Basis.Slerp(target, 8f * (float)delta);
        }
        else
        {
            velocity.X = Mathf.MoveToward(
                Entity.GetComponent<CCharacter>().Character.Velocity.X,
                0,
                character.Cmovement.Speed
                );
            velocity.Z = Mathf.MoveToward(
                Entity.GetComponent<CCharacter>().Character.Velocity.Z,
                0,
                character.Cmovement.Speed
                );
        }

        character.Velocity = velocity;
        character.MoveAndSlide();
    }
}
