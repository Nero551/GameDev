using Godot;
using System;

public partial class StraightLine : Node2D
{
    [Export] public float Slope;
    [Export] public float Angle;
    [Export] public float AngleRad;
    [Export] public Color Color;
    [Export] public string LineName;
    [Export] public Vector2 A;
    [Export] public Vector2 B;
}
