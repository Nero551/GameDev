using Godot;
using System;

public partial class Player
{
	public const float Speed = 5.0f;
	public const float JumpVelocity = 4.5f;

	public void MovementPhysics(double delta)
	{
		Vector3 velocity = Velocity;

		if (!IsOnFloor())
		{
			velocity += GetGravity() * (float)delta;
		}
		else if (CheckState("Jumping"))
		{
			RemoveState("Jumping");
		}

		if (Input.IsActionJustPressed("Jump") && IsOnFloor())
		{
			AddState("Jumping");
			velocity.Y = JumpVelocity;
		}

		Vector2 inputDir = Input.GetVector("Left", "Right", "Forward", "Back");
		Vector3 direction = (Transform.Basis * new Vector3(inputDir.X, 0, inputDir.Y)).Normalized();

		var camera = GetNode<Camera3D>("SpringArm3D/Camera3D");
		direction = direction.Rotated(Vector3.Up, camera.GlobalRotation.Y);

		if (direction != Vector3.Zero)
		{
			velocity.X = direction.X * Speed;
			velocity.Z = direction.Z * Speed;

			PlayAnim("Run");
			// Vector3 target = GlobalPosition + direction;
			// LookAt(target, Vector3.Up);
		}
		else
		{
			velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
			velocity.Z = Mathf.MoveToward(Velocity.Z, 0, Speed);

			PlayAnim("Idle");
		}

		Velocity = velocity;
		MoveAndSlide();
	}

}
