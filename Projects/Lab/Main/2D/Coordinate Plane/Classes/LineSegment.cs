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

    public void RegisterData(LineSegment line, Vector2 a, Vector2 b)
    {
        var meshInstance = line.GetNode<MeshInstance2D>("Line");
        this.A = new Vector2(a.X / CartesianPlane.BasisX, -a.Y / CartesianPlane.BasisY);
        this.B = new Vector2(b.X / CartesianPlane.BasisX, -b.Y / CartesianPlane.BasisY);
        this.Length = (b - a).Length();
        this.AngleRad = (b - a).Angle();
        this.Angle = Mathf.RadToDeg(this.AngleRad);
        this.Slope = Mathf.Tan(this.AngleRad);
        this.LineName = this.Name;
        this.Color = meshInstance.Modulate;
    }

}
