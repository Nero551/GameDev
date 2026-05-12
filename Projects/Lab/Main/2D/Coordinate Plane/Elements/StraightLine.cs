using Godot;
using System;

public partial class CartesianPlane
{
    //Vector Method
    public StraightLine StraightLine(Vector2 a, Vector2 b, Color color = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/StraightLine.tscn");
        StraightLine line = scene.Instantiate<StraightLine>();
        var meshInstance = line.GetNode<MeshInstance2D>("Line/LineMesh");
        var arrow1 = line.GetNode<MeshInstance2D>("Arrow1/Arrow1Mesh");
        var arrow2 = line.GetNode<MeshInstance2D>("Arrow2/Arrow2Mesh");

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

        line.AngleRad = vAB.Angle();
        line.Angle = Mathf.RadToDeg(line.Rotation);
        line.Slope = Mathf.Tan(line.AngleRad);
        line.Color = meshInstance.Modulate;
        line.LineName = line.Name;
        line.A = new Vector2(a.X / BasisX, a.Y / BasisY);
        line.B = new Vector2(b.X / BasisX, b.Y / BasisY);

        GetNode<Node2D>("My Stuff").AddChild(line);

        return line;
    }

    //Slope Method
    public StraightLine StraightLine(Vector2 a, float slope, Color color = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/StraightLine.tscn");
        StraightLine line = scene.Instantiate<StraightLine>();

        float theta = Mathf.Atan(slope);
        float cos = Mathf.Cos(theta);
        float sin = Mathf.Sin(theta);

        //* B is NOT a position its a DIRECTION vector
        Vector2 b = Vector2(cos, sin);

        line.Position = (a + b) / 2;
        line.GetNode<Node2D>("Line").Scale = new Vector2(Size * 2, 0.5f);
        line.Rotation = theta;

        line.GetNode<Node2D>("Arrow1").Position = new Vector2(-line.GetNode<Node2D>("Line").Scale.X / 2, 0);
        line.GetNode<Node2D>("Arrow2").Position = new Vector2(line.GetNode<Node2D>("Line").Scale.X / 2, 0);

        line.Name = "Straight Line: " + (a + b).ToString();

        var meshInstance = line.GetNode<MeshInstance2D>("Line/LineMesh");
        var arrow1 = line.GetNode<MeshInstance2D>("Arrow1/Arrow1Mesh");
        var arrow2 = line.GetNode<MeshInstance2D>("Arrow2/Arrow2Mesh");

        meshInstance.Modulate = color == default ? Colors.DimGray : color;
        arrow1.Modulate = color == default ? Colors.DimGray : color;
        arrow2.Modulate = color == default ? Colors.DimGray : color;

        line.Slope = Mathf.Tan(line.Rotation);
        line.AngleRad = line.Rotation;
        line.Angle = Mathf.RadToDeg(line.Rotation);
        line.Color = meshInstance.Modulate;
        line.LineName = line.Name;
        line.A = new Vector2(a.X / BasisX, a.Y / BasisY);
        line.B = new Vector2(b.X / BasisX, b.Y / BasisY);

        GetNode<Node2D>("My Stuff").AddChild(line);

        return line;
    }
}
