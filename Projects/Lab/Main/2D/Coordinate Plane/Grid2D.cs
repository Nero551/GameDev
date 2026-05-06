using Godot;
using System;

public partial class Grid2D : Node
{
    public Vector2 Origin = new Vector2(0, 0);
    public int BasisX = 1;
    public int BasisY = 1;

    public override void _Ready()
    {
        CreateGrid(20, 20);
        CreateLine(Origin, new Vector2(0, 4));
        CreateLine(new Vector2(0, 4), new Vector2(3, 0));
    }

    //this will be a game where u can move between points in the grid and make lines real-time.

    public void CreateGrid(int sizeX, int sizeY)
    {
        CreatePoint(Origin, Colors.Green);

        for (int x = -sizeX; x <= sizeX; x += BasisX)
        {
            for (int y = -sizeY; y <= sizeY; y += BasisY)
            {
                if (x == 0 && y == 0)
                {
                    continue;
                }
                CreatePoint(new Vector2(x, y));
            }
        }
    }

    public Node2D CreatePoint(Vector2 pos, Color color = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/point.tscn");
        Node2D point = scene.Instantiate<Node2D>();

        point.Position = new Vector2(pos.X, pos.Y * -1);

        point.Name = pos.ToString();

        point.GetNode<MeshInstance2D>("MeshInstance2D").Modulate = color == default ? Colors.White : color;


        AddChild(point);

        return point;
    }

    public void CreateLine(Vector2 a, Vector2 b, Color color = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/line.tscn");
        Node2D line = scene.Instantiate<Node2D>();

        var meshInstance = line.GetNode<MeshInstance2D>("MeshInstance2D");
        var cylinder = meshInstance.Mesh as CapsuleMesh;

        line.Position = ((new Vector2(a.X, a.Y * -1) + new Vector2(b.X, b.Y * -1))) / 2;
        cylinder.Height = (b - a).Length() * 4;
        line.Rotation = (b - a).Angle();
        GD.Print(Mathf.RadToDeg(line.Rotation));

        line.Name = (a + b).ToString();

        meshInstance.Modulate = color == default ? Colors.Black : color;


        AddChild(line);
    }
}
