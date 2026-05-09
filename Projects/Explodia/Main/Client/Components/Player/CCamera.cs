using Godot;
using System;

public partial class CCamera : Component
{
    private ICamerable camerable;
    
    int MaxSpringLength = 6;
    int MinSpringLength = 1;

    [Export] public float MouseSensitivity = 0.002f;
    float horizontalRotation;
    float verticalRotation;

    protected override void OnInit()
    {
        camerable = Entity.GetInterface<ICamerable>();
        Input.MouseMode = Input.MouseModeEnum.Captured;
    }

    public void SwitchCam()
    {
        if (!World.DebugCam.Current)
        {
            World.DebugCam.Current = true;
        }
        else
        {
            camerable.SpringArm.GetNode<Camera3D>("Camera3D").Current = true;
        }
    }

    public void ZoomCamera()
    {
        if (Input.IsActionJustPressed("Zoom In") && camerable.SpringArm.SpringLength > MinSpringLength)
        {
            camerable.SpringArm.SpringLength -= 0.5f;
        }
        else if (Input.IsActionJustPressed("Zoom Out") && camerable.SpringArm.SpringLength < MaxSpringLength)
        {
            camerable.SpringArm.SpringLength += 0.5f;
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

            camerable.SpringArm.Rotation = new Vector3(verticalRotation, horizontalRotation, 0);
        }
    }
}
