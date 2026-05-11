using Godot;
using System;

public partial class CCamera : Component
{
    public SpringArm3D SpringArm;

    int MaxSpringLength = 6;
    int MinSpringLength = 1;

    [Export] public float MouseSensitivity = 0.002f;
    float horizontalRotation;
    float verticalRotation;

    protected override void OnInit()
    {
        SpringArm = Entity.Owner.GetNode<SpringArm3D>("SpringArm3D");
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
            SpringArm.GetNode<Camera3D>("Camera3D").Current = true;
        }
    }

    public void ZoomCamera()
    {
        if (Input.IsActionJustPressed("Zoom In") && SpringArm.SpringLength > MinSpringLength)
        {
            SpringArm.SpringLength -= 0.5f;
        }
        else if (Input.IsActionJustPressed("Zoom Out") && SpringArm.SpringLength < MaxSpringLength)
        {
            SpringArm.SpringLength += 0.5f;
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

            SpringArm.Rotation = new Vector3(verticalRotation, horizontalRotation, 0);
        }
    }

    public void UpdateCam()
    {
        Vector3 forward = -SpringArm.GlobalTransform.Basis.Z;
        Vector3 right = SpringArm.GlobalTransform.Basis.X;
        forward.Y = 1;
        right.Y = 1;
        forward = forward.Normalized();
        right = right.Normalized();

        var vel = Entity.GetComponent<CCharacter>().Character.Cmovement.velocity;
        Entity.GetComponent<CCharacter>().Character.Cmovement.velocity = right * vel.X + forward * vel.Z;
        GD.Print(Entity.GetComponent<CCharacter>().Character.Cmovement.velocity);
    }
}
