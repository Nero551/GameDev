using Godot;
using System;

public partial class CCamera : Component
{
    public SpringArm3D SpringArm;
    public float MouseSensitivity = 0.002f;

    public int MaxSpringLength = 6;
    public int MinSpringLength = 1;

    float horizontalRotation;
    float verticalRotation;

    protected override void OnInit()
    {
        SpringArm = ComponentHost.Owner.GetNode<SpringArm3D>("SpringArm3D");
        Input.MouseMode = Input.MouseModeEnum.Captured;
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

    public void ApplyCamRelativeMovement()
    {
        Vector3 forward = -SpringArm.GlobalTransform.Basis.Z;
        Vector3 right = SpringArm.GlobalTransform.Basis.X;
        forward.Y = 0;
        right.Y = 0;
        forward = forward.Normalized();
        right = right.Normalized();

        Vector3 vel = ComponentHost.GetComponent<CCharacter>().Character.cMovement.MovementVelocity;

        Vector3 direction = right * vel.X + forward * vel.Z;
        direction.Y = vel.Y;
        ComponentHost.GetComponent<CCharacter>().Character.cMovement.MovementVelocity = direction;
    }
}
