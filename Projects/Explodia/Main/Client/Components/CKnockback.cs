using Godot;
using System;

public partial class CKnockback : Component
{
    private IKnockable knockable;
    protected override void OnInit()
    {
        knockable = Owner as IKnockable;
    }

    public void Knockback(Vector3 force)
    {
        knockable.Velocity += force;
        GD.Print(knockable.Velocity);
    }
}
