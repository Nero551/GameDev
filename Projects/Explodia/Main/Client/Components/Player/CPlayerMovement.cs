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
        //TODO refactor this. all of it. this shouldnot even be here. it should be in Movement Component.
        Vector3 velocity = character.Velocity;

        if (!character.IsOnFloor())
        {
            velocity += character.GetGravity() * (float)delta;
        }

        if (Input.IsActionJustPressed("Jump") && character.IsOnFloor())
        {
            velocity.Y = character.Cmovement.JumpPower;
        }

        Vector3 forward = -Entity.GetComponent<CCamera>().SpringArm.GlobalTransform.Basis.Z;
        Vector3 right = Entity.GetComponent<CCamera>().SpringArm.GlobalTransform.Basis.X;
        forward.Y = 0;
        right.Y = 0;
        forward = forward.Normalized();
        right = right.Normalized();

        velocity = new Vector3(character.Cmovement.MoveDirection.X, 0, character.Cmovement.MoveDirection.Y);
        velocity =
        (right * character.Cmovement.MoveDirection.X +
         forward * character.Cmovement.MoveDirection.Y
        ).Normalized();

        if (velocity != Vector3.Zero)
        {
            velocity.X *= character.Cmovement.Speed;
            velocity.Z *= character.Cmovement.Speed;

            //? Smooths character rotation 
            // I dont understand how this works but it works
            Vector3 targetDir = (
                character.GlobalPosition + velocity -
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
