using Godot;
using System;

public partial class CartesianPlane
{
    public Ray Ray(Vector2 a, Vector2 b, Color color = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/Ray.tscn");
        Ray line = scene.Instantiate<Ray>();
        var meshInstance = line.GetNode<MeshInstance2D>("Line/LineMesh");
        var arrow = line.GetNode<MeshInstance2D>("Arrow/ArrowMesh");

        Vector2 vAB = b - a;

        line.Position = a;
        line.GetNode<Node2D>("Line").Scale = new Vector2(vAB.Length(), 0.5f);
        line.Rotation = (b - a).Angle();

        line.GetNode<Node2D>("Arrow").Position = new Vector2(line.GetNode<Node2D>("Line").Scale.X, 0);

        line.Name =  "Ray: " + (a + b).ToString();
        meshInstance.Modulate = color == default ? Colors.DimGray : color;
        arrow.Modulate = color == default ? Colors.DimGray : color;

        GetNode<Node2D>("My Stuff").AddChild(line);

        return line;
    }
}
