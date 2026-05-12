using Godot;
using System;

public partial class CartesianPlane
{
    //Vector Method
    public void StraightLine(Vector2 a, Vector2 b, Color color = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/StraightLine.tscn");
        Node2D line = scene.Instantiate<Node2D>();
        var meshInstance = line.GetNode<MeshInstance2D>("Line/LineMesh");
        var arrow1 = line.GetNode<MeshInstance2D>("Arrow1/Arrow1Mesh");
        var arrow2 = line.GetNode<MeshInstance2D>("Arrow2/Arrow2Mesh");

        a = new Vector2(a.X, -a.Y);
        b = new Vector2(b.X, -b.Y);
        Vector2 vAB = b - a;

        line.Position = (a + b) / 2;
        line.Rotation = vAB.Angle();
        line.GetNode<Node2D>("Line").Scale = new Vector2(Size * 2, 0.5f);

        line.GetNode<Node2D>("Arrow1").Position = new Vector2(-line.GetNode<Node2D>("Line").Scale.X / 2, 0);
        line.GetNode<Node2D>("Arrow2").Position = new Vector2(line.GetNode<Node2D>("Line").Scale.X / 2, 0);

        line.Name = "Straight Line: " + (a + b).ToString();
        meshInstance.Modulate = color == default ? Colors.DimGray : color;
        arrow1.Modulate = color == default ? Colors.DimGray : color;
        arrow2.Modulate = color == default ? Colors.DimGray : color;

        GetNode<Node2D>("My Stuff").AddChild(line);
    }

    //Slope Method
    public void StraightLine(Vector2 a, float slope, Color color = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/StraightLine.tscn");
        Node2D line = scene.Instantiate<Node2D>();

        float theta  = Mathf.Atan(slope);
        float cos = Mathf.Cos(theta);
        float sin = Mathf.Sin(theta);

        a = new Vector2(a.X, -a.Y);
        Vector2 b = new Vector2(cos, -sin);
        Vector2 vAB = b - a;

        line.Position = (a + b) / 2;
        line.GetNode<Node2D>("Line").Scale = new Vector2(Size * 2, 0.5f);
        line.Rotation = vAB.Angle();

        line.GetNode<Node2D>("Arrow1").Position = new Vector2(-line.GetNode<Node2D>("Line").Scale.X / 2, 0);
        line.GetNode<Node2D>("Arrow2").Position = new Vector2(line.GetNode<Node2D>("Line").Scale.X / 2, 0);

        line.Name = "Straight Line: " + (a + b).ToString();

        var meshInstance = line.GetNode<MeshInstance2D>("Line/LineMesh");
        var arrow1 = line.GetNode<MeshInstance2D>("Arrow1/Arrow1Mesh");
        var arrow2 = line.GetNode<MeshInstance2D>("Arrow2/Arrow2Mesh");

        meshInstance.Modulate = color == default ? Colors.DimGray : color;
        arrow1.Modulate = color == default ? Colors.DimGray : color;
        arrow2.Modulate = color == default ? Colors.DimGray : color;

        GetNode<Node2D>("My Stuff").AddChild(line);
    }

    
}
