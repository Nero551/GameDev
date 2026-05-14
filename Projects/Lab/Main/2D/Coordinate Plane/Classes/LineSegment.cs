using Godot;
using System;

public partial class LineSegment : Node2D
{
    [Export] public Vector2 A;
    [Export] public Vector2 B;
    [Export] public float Length;
    [Export] public float Angle;
    [Export] public float AngleRad;
    [Export] public float Slope;
    [Export] public string LineName;
    [Export] public Color Color;
    [Export] public Vector2 DirectionVector;

    public void RegisterData(LineSegment line, Vector2 a, Vector2 b)
    {
        var meshInstance = line.GetNode<MeshInstance2D>("Line");
        A = new Vector2(a.X / CartesianPlane.BasisX, -a.Y / CartesianPlane.BasisY);
        B = new Vector2(b.X / CartesianPlane.BasisX, -b.Y / CartesianPlane.BasisY);
        Length = (b - a).Length();
        AngleRad = (b - a).Angle();
        Angle = Mathf.RadToDeg(AngleRad);
        Slope = Mathf.Tan(AngleRad);
        LineName = Name;
        Color = meshInstance.Modulate;
        DirectionVector = new Vector2(Mathf.Cos(AngleRad), Mathf.Sin(AngleRad));
    }
}
