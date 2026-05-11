using Godot;
using System;

public partial class CartesianPlane
{
    public Node2D CreatePoint(Node parent, Vector2 pos, Color color = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/point.tscn");
        Node2D point = scene.Instantiate<Node2D>();
        pos = new Vector2(pos.X * BasisX, -pos.Y * BasisY);
        point.Position = pos;

        point.Name = pos.ToString();

        point.GetNode<MeshInstance2D>("MeshInstance2D").Modulate = color == default ? Colors.White : color;


        parent.AddChild(point);

        return point;
    }
}
