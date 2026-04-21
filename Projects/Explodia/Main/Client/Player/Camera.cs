using Godot;
using System;

public partial class Player
{
	// Called when the node enters the scene tree for the first time.
	int MaxCamFOV = 125;
	int MinCamFOV = 40;
	[Export] public float MouseSensitivity = 0.002f;


	public void Test(double delta)
	{
		if (Input.IsActionJustPressed("ExitGame"))
		{
			Input.MouseMode = Input.MouseModeEnum.Visible;
		}
	}
	public void InitCamera()
	{
		Input.MouseMode = Input.MouseModeEnum.Captured;
	}
	public void RotateCamera(InputEvent @event)
	{
		if (@event is InputEventMouseMotion mouseMotion && Input.MouseMode is Input.MouseModeEnum.Captured)
		{
			var springArm = GetNode<SpringArm3D>("SpringArm3D");
			springArm.RotateY(-mouseMotion.Relative.X * MouseSensitivity);
			springArm.RotateX(-mouseMotion.Relative.Y * MouseSensitivity);

			springArm.Rotation = new Vector3(
				Mathf.Clamp(springArm.Rotation.X, -Mathf.Pi / 2, Mathf.Pi / 4),
				Mathf.Wrap(springArm.Rotation.Y, 0, Mathf.Tau),
				Rotation.Z);
		}
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	// public override void _Process(double delta)
	// {
	// 	if (Input.IsActionJustPressed("Increase FOV") && Fov > MaxCamFOV)
	// 	{
	// 		Fov += 5;
	// 	}
	// 	else if (Input.IsActionJustPressed("Decrease FOV") && Fov > MinCamFOV)
	// 	{
	// 		Fov -= 5;
	// 	}
	// }
}
