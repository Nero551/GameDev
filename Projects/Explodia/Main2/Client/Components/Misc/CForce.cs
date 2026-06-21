using Godot;
using System;

public partial class CForce : Component
{
    public void Knockback(Vector3 force)
    {
        ComponentHost.GetComponent<CMovement>().Force += force;
    }
    public void Pull(Vector3 force)
    {
        ComponentHost.GetComponent<CMovement>().Force -= force;
    }
}
