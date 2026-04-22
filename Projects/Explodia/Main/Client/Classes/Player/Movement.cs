using Godot;
using System;

public partial class Player
{
	public const float WalkSpeed = 5.0f;
	public const float RunSpeed = 10f;
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
			velocity.X = direction.X * WalkSpeed;
			velocity.Z = direction.Z * WalkSpeed;

			PlayAnim("Run");
			var arm = GetNode<Node3D>("__Animation Dummy_Armature");

			//? I dont understand this part at all but it works
			//? Smooths character rotation 
			Vector3 targetDir = (GlobalPosition + direction - arm.GlobalPosition).Normalized();
			Basis target = Basis.LookingAt(targetDir, Vector3.Up);

			arm.Basis = arm.Basis.Slerp(target, 8f * (float)delta);
		}
		else
		{
			velocity.X = Mathf.MoveToward(Velocity.X, 0, WalkSpeed);
			velocity.Z = Mathf.MoveToward(Velocity.Z, 0, WalkSpeed);

			PlayAnim("Idle");
		}
		Velocity = velocity;
		MoveAndSlide();
	}

}
