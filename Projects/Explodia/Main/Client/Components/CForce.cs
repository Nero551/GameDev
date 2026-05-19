using Godot;
using System;

public partial class CForce : Component
{
    public void Knockback(Vector3 force)
    {
        Entity.GetComponent<CMovement>().Force += force;
    }
    public void Pull(Vector3 force)
    {
        Entity.GetComponent<CMovement>().Force -= force;
    }
}
