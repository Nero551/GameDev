using Godot;
using System;

public partial class Point : Node2D
{
    [Export] public float X;
    [Export] public float Y;
    [Export] public Color Color;
    [Export] public string PointName;

    public static Point Create(MathVector2 pos, string name = default, Color color = default, Node parent = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/Point.tscn");
        Point point = scene.Instantiate<Point>();
        point.X = pos.X;
        point.Y = pos.Y;

        point.PointName = name == default ? "Point" : name;
        point.Color = color == default ? Colors.White : color;

        parent = parent == default ? MathWorld.World : parent;
        parent.AddChild(point);

        return point;
    }

    public override void _Process(double delta)
    {
        Name = PointName;
        Position = Converter.MathToRender(new MathVector2(X, Y));
        GetNode<MeshInstance2D>("MeshInstance2D").Modulate = Color;
    }
}
