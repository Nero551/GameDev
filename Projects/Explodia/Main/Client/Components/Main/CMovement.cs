using Godot;
using System;

public partial class CMovement : Component
{
    private IMovable movable;
    protected override void OnInit()
    {
        movable = Owner as IMovable;
    }

    public bool IsMoving()
    {
        Vector3 horizontal = new Vector3(movable.Velocity.X, 0, movable.Velocity.Z);
        return horizontal.LengthSquared() > 0.01f;
    }
}
