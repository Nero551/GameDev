using Godot;
using System;

public partial class CMovement : Component
{
    private IMovable IMovable;
    protected override void OnInit()
    {
        IMovable = Owner as IMovable;
    }

    public bool IsMoving()
    {
        Vector3 horizontal = new Vector3(IMovable.Velocity.X, 0, IMovable.Velocity.Z);
        return horizontal.LengthSquared() > 0.01f;
    }
}
