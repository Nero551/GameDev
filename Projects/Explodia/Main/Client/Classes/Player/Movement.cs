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

		Vector2 inputDir = Input.GetVector("Left", "Right", "Back", "Forward");
		var forward = -springArm.GlobalTransform.Basis.Z;
		var right = springArm.GlobalTransform.Basis.X;
		forward.Y = 0;
		right.Y = 0;
		forward = forward.Normalized();
		right = right.Normalized();

		Vector3 direction = (right * inputDir.X + forward * inputDir.Y).Normalized();

		if (direction != Vector3.Zero)
		{
			velocity.X = direction.X * Speed;
			velocity.Z = direction.Z * Speed;

			PlayAnim("Run");
			GetNode<Node3D>("__Animation Dummy_Armature").LookAt(GlobalPosition + direction);
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
