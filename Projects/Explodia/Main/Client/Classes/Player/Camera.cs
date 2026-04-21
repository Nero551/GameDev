using Godot;
using System;

public partial class Player
{
	// Called when the node enters the scene tree for the first time.
	private SpringArm3D springArm;
	
	int MaxSpringLength = 6;
	int MinSpringLength = 1;
	
	[Export] public float MouseSensitivity = 0.002f;

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
		if (@event is InputEventMouseMotion mouseMotion && Input.MouseMode is Input.MouseModeEnum.Captured)
		{
			springArm.RotateY(-(mouseMotion.Relative.X * MouseSensitivity));
			springArm.RotateX(-(mouseMotion.Relative.Y * MouseSensitivity));

			springArm.Rotation = new Vector3(
				Mathf.Clamp(springArm.Rotation.X, -Mathf.Pi / 2, Mathf.Pi / 4),
				Mathf.Wrap(springArm.Rotation.Y, -Mathf.Tau, Mathf.Tau),
				Rotation.Z);
		}
	}

}
