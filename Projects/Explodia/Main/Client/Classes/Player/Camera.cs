using Godot;
using System;

public partial class Player
{
	private SpringArm3D springArm;
	
	int MaxSpringLength = 6;
	int MinSpringLength = 1;
	
	[Export] public float MouseSensitivity = 0.002f;
	float horizontalRotation;
	float verticalRotation;

	public void Test(InputEvent @event)
	{
		if (Input.IsActionJustPressed("ExitGame"))
		{
			Input.MouseMode = Input.MouseModeEnum.Visible;
		}
	}
	public void InitCamera()
	{
		springArm = GetNode<SpringArm3D>("SpringArm3D");
		Input.MouseMode = Input.MouseModeEnum.Captured;
	}

	public void ZoomCamera()
	{
		if (Input.IsActionJustPressed("Zoom In") && springArm.SpringLength > MinSpringLength)
		{
			springArm.SpringLength -= 0.5f;
		}
		else if (Input.IsActionJustPressed("Zoom Out") && springArm.SpringLength < MaxSpringLength)
		{
			springArm.SpringLength += 0.5f;
		}

	}
	public void RotateCamera(InputEvent @event)
	{
		if (@event is InputEventMouseMotion mouseMotion &&
			Input.MouseMode == Input.MouseModeEnum.Captured)
		{
			horizontalRotation -= mouseMotion.Relative.X * MouseSensitivity;
			verticalRotation -= mouseMotion.Relative.Y * MouseSensitivity;

			verticalRotation = Mathf.Clamp(verticalRotation, Mathf.DegToRad(-75), Mathf.DegToRad(45));

			springArm.Rotation = new Vector3(verticalRotation, horizontalRotation, 0);
		}
	}

}
