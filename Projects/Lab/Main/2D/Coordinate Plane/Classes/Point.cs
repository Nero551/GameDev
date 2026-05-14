using Godot;
using System;

public partial class Point : Node2D
{
    public static Point Create(MathVector2 pos, Node parent = default, Color color = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/Point.tscn");
        Point point = scene.Instantiate<Point>();
        point.Position = Converter.MathToRender(pos);

        point.Name = pos.ToString();

        point.GetNode<MeshInstance2D>("MeshInstance2D").Modulate = color == default ? Colors.White : color;

        parent = parent == default ? MathWorld.World : parent;
        parent.AddChild(point);

        return point;
    }
    public override void _Process(double delta)
    {
    }
}
