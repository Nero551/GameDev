using Godot;
using System;

public partial class Player
{
	// Called when the node enters the scene tree for the first time.
	int MaxCamFOV = 125;
	int MinCamFOV = 40;
	[Export] public float MouseSensitivity = 0.002f;

	public void InitCamera()
	{
		Input.MouseMode = Input.MouseModeEnum.Captured;
	}
	public void RotateCamera(InputEvent @event)
	{
		if (@event is InputEventMouseMotion mouseMotion && Input.MouseMode is Input.MouseModeEnum.Captured)
		{
			// GD.Print(mouseMotion.Relative);
			//TODO The issue here is that we are clamping and wrapping the value that is added to the rotation,
			//TODO not the rotation itself.
			//TODO FIX pls
			var springArm = GetNode<SpringArm3D>("SpringArm3D");
			springArm.RotateY(Mathf.Wrap(-mouseMotion.Relative.X * MouseSensitivity, 0, Mathf.Tau));
			springArm.RotateX(Mathf.Clamp(-mouseMotion.Relative.Y * MouseSensitivity, -Mathf.Pi / 2, Mathf.Pi / 4));
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
