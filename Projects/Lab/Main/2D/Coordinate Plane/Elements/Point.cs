using Godot;
using System;

public partial class Point : Element<Point.CalculationModes>
{
    public enum CalculationModes
    {
        None,
    }

    [Export] public float X;
    [Export] public float Y;
    [Export] public Color Color;

    public static Point Create(MathVector2 pos, string name = default, Color color = default, Node parent = default)
    {
        PackedScene scene = SceneLoader.Load("Point");
        Point point = scene.Instantiate<Point>();
        point.X = pos.X;
        point.Y = pos.Y;

        point.ElementName = name == default ? "Point" : name;
        point.Color = color == default ? Colors.White : color;
        parent = parent == default ? CartesianPlane.Plane.GetNodeOrNull<Node2D>("Content/Points") : parent;

        parent.AddChild(point);
        return point;
    }

    public override void _Process(double delta)
    {
        Name = ElementName;
        Position = Converter.VectorMathToRender(new MathVector2(X, Y));
        GetNode<MeshInstance2D>("MeshInstance2D").Modulate = Color;
    }
}
