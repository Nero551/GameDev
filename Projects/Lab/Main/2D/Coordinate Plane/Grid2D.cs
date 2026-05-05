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
    }

    public void CreateGrid(int sizeX, int sizeY)
    {
        CreatePoint(Origin);

        for (int i = 1; i <= sizeX; i += BasisX)
        {
            CreatePoint(new Vector2(i, 0));
            CreatePoint(new Vector2(-i, 0));
        }

        for (int i = 1; i <= sizeY; i += BasisY)
        {
            CreatePoint(new Vector2(0, i));
            CreatePoint(new Vector2(0, -i));
        }
    }

    public Point2D CreatePoint(Vector2 pos, Color color = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/point.tscn");
        Point2D point = scene.Instantiate<Point2D>();

        point.Position = pos;

        point.Name = pos.ToString();

        point.GetNode<MeshInstance2D>("MeshInstance2D").Modulate = color == default ? Colors.White : color;


        AddChild(point);

        return point;
    }
}
