using Godot;
using System;

public partial class Player
{

	public void MovementPhysics(double delta)
	{
		Vector3 velocity = Character.Velocity;

		if (!Character.IsOnFloor())
		{
			velocity += Character.GetGravity() * (float)delta;
		}

		if (Input.IsActionJustPressed("Jump") && Character.IsOnFloor())
		{
			velocity.Y = Character.JumpPower;
		}

		Vector3 forward = -springArm.GlobalTransform.Basis.Z;
		Vector3 right = springArm.GlobalTransform.Basis.X;
		forward.Y = 0;
		right.Y = 0;
		forward = forward.Normalized();
		right = right.Normalized();

		Vector3 direction = (right * Character.MoveDirection.X + forward * Character.MoveDirection.Y).Normalized();

		if (direction != Vector3.Zero)
		{
			velocity.X = direction.X * Character.Speed;
			velocity.Z = direction.Z * Character.Speed;

			//? Smooths character rotation 
			// I dont understand how this works but it works
			Vector3 targetDir = (Character.GlobalPosition + direction - Character.Rig.GlobalPosition).Normalized();
			Basis target = Basis.LookingAt(targetDir, Vector3.Up);

			Character.Rig.Basis = Character.Rig.Basis.Slerp(target, 8f * (float)delta);
		}
		else
		{
			velocity.X = Mathf.MoveToward(Character.Velocity.X, 0, Character.Speed);
			velocity.Z = Mathf.MoveToward(Character.Velocity.Z, 0, Character.Speed);
		}

		Character.Velocity = velocity;
		Character.MoveAndSlide();
	}

}
