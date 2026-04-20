using Godot;
using System;

public partial class Player
{
	public const float Speed = 5.0f;
	public const float JumpVelocity = 4.5f;

	public void Test(double delta)
	{
		if (Input.IsActionJustPressed("ExitGame"))
		{
			Input.MouseMode = Input.MouseModeEnum.Visible;
		}
	}

	public void MovementPhysics(double delta)
	{
		Vector3 velocity = Velocity;

		// Add the gravity.
		if (IsOnFloor())
		{
			if (ActiveStates["Walking"])
			{
				RemoveState("Walking");
			}
		}
		else
		{
			velocity += GetGravity() * (float)delta;
		}

		// Handle Jump.
		if (Input.IsActionJustPressed("Jump") && IsOnFloor())
		{
			AddState("Jumping");
			velocity.Y = JumpVelocity;
		}

		// Get the input direction and handle the movement/deceleration.
		// As good practice, you should replace UI actions with custom gameplay actions.
		Vector2 inputDir = Input.GetVector("Left", "Right", "Forward", "Back");
		Vector3 direction = (Transform.Basis * new Vector3(inputDir.X, 0, inputDir.Y)).Normalized();
		if (direction != Vector3.Zero)
		{
			velocity.X = direction.X * Speed;
			velocity.Z = direction.Z * Speed;
			AddState("Walking");

		}
		else
		{
			velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
			velocity.Z = Mathf.MoveToward(Velocity.Z, 0, Speed);
			RemoveState("Walking");
		}

		Velocity = velocity;
		MoveAndSlide();
	}

}
