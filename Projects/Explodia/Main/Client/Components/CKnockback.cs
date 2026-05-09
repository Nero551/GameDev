using Godot;
using System;

public partial class CKnockback : Component
{
    protected override void OnInit()
    {
    }

    public void Knockback(Vector3 force)
    {
        Entity.GetInterface<IVelocity>().Velocity += force;
    }
}
