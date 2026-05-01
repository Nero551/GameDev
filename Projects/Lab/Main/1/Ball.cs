using Godot;
using System;

public partial class Ball : Node3D
{
    [Export] Vector3 Pos;
    [Export] Vector3 Scl;
    [Export] Vector3 Rot;

    public override void _Ready()
    {
        base._Ready();
    }

    public override void _PhysicsProcess(double delta)
    {
        base._PhysicsProcess(delta);

        Pos = Position;
        Scl = Scale;
        Rot = Rotation;
    }
}
