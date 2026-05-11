using Godot;
using System;

public partial class CartesianPlane
{
    public void PlaneLine(Vector2 a, Vector2 b)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/LineSegment.tscn");
        Node2D line = scene.Instantiate<Node2D>();
        var meshInstance = line.GetNode<MeshInstance2D>("Line");

        a = new Vector2(a.X, -a.Y);
        b = new Vector2(b.X, -b.Y);
        Vector2 vAB = b - a;

        line.Position = a;
        line.Scale = new Vector2(Size * 2, 0.5f);
        line.Rotation = (b - a).Angle();

        line.Name = (a + b).ToString();

        meshInstance.Modulate = Colors.DimGray;
        GetNode<Node2D>("Core/Plane").AddChild(line);

    }

    public void AxisLine(Vector2 a, Vector2 b)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/StraightLine.tscn");
        Node2D line = scene.Instantiate<Node2D>();
        var meshInstance = line.GetNode<MeshInstance2D>("Line");
        var arrow1 = line.GetNode<MeshInstance2D>("Arrow1");
        var arrow2 = line.GetNode<MeshInstance2D>("Arrow2");

        a = new Vector2(a.X, -a.Y);
        b = new Vector2(b.X, -b.Y);
        Vector2 vAB = b - a;

        line.Position = (a + b) / 2;
        line.Scale = new Vector2(Size * 2, 0.5f);
        line.Rotation = (b - a).Angle();

        arrow1.Position = a;
        arrow2.Position = b;

        GetNode<Node2D>("Core/Axis").AddChild(line);
        if (line.Rotation == 0)
        {
            arrow1.Modulate = Colors.IndianRed;
            arrow2.Modulate = Colors.IndianRed;

            meshInstance.Modulate = Colors.IndianRed;
            line.Name = "X Axis";
        }
        else
        {
            arrow1.Modulate = Colors.LightGreen;
            arrow2.Modulate = Colors.LightGreen;

            meshInstance.Modulate = Colors.LightGreen;
            line.Name = "Y Axis";
        }
    }

    public void LineSegment(Vector2 a, Vector2 b, Color color = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/LineSegment.tscn");
        Node2D line = scene.Instantiate<Node2D>();
        var meshInstance = line.GetNode<MeshInstance2D>("Line");

        a = new Vector2(a.X * BasisX, -a.Y * BasisY);
        b = new Vector2(b.X * BasisX, -b.Y * BasisY);
        Vector2 vAB = b - a;

        line.Position = a;
        line.Scale = new Vector2(vAB.Length(), 0.5f);
        line.Rotation = (b - a).Angle();

        line.Name = (a + b).ToString();

        meshInstance.Modulate = color == default ? Colors.DimGray : color;
        GetNode<Node2D>("My Stuff").AddChild(line);
    }

    public void Ray(Vector2 a, Vector2 b, Color color = default)
    {

    }

    //TODO- straight lines or anything with arrows dont work
    public void StraightLine(Vector2 a, Vector2 b, Color color = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/StraightLine.tscn");
        Node2D line = scene.Instantiate<Node2D>();
        var meshInstance = line.GetNode<MeshInstance2D>("Line");
        var arrow1 = line.GetNode<MeshInstance2D>("Arrow1");
        var arrow2 = line.GetNode<MeshInstance2D>("Arrow2");

        a = new Vector2(a.X * BasisX, -a.Y * BasisY);
        b = new Vector2(b.X * BasisX, -b.Y * BasisY);
        Vector2 vAB = b - a;

        line.Position = (a + b) / 2;
        line.Scale = new Vector2(Size * 2, 0.5f);
        line.Rotation = (b - a).Angle();

        line.Name = (a + b).ToString();

        arrow1.Position = a;
        arrow2.Position = b;

        meshInstance.Modulate = color == default ? Colors.DimGray : color;
        arrow1.Modulate = color == default ? Colors.DimGray : color;
        arrow2.Modulate = color == default ? Colors.DimGray : color;

        GetNode<Node2D>("My Stuff").AddChild(line);
    }
}
