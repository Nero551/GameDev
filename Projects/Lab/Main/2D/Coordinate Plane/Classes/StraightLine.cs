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

    public void RegisterData(StraightLine line, Vector2 a, Vector2 b)
    {
        var meshInstance = line.GetNode<MeshInstance2D>("Line/LineMesh");
        Vector2 vAB = b - a;
        this.AngleRad = vAB.Angle();
        this.Angle = Mathf.RadToDeg(this.AngleRad);
        this.Slope = Mathf.Tan(this.AngleRad);
        this.Color = meshInstance.Modulate;
        this.LineName = line.Name;
        this.A = new Vector2(a.X / CartesianPlane.BasisX, -a.Y / CartesianPlane.BasisY);
        this.B = new Vector2(b.X / CartesianPlane.BasisX, -b.Y / CartesianPlane.BasisY);
    }
}
