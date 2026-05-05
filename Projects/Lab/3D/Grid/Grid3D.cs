using Godot;
using System;

public partial class Grid3D : Node
{
    public Vector3 Origin = new Vector3(0, 0, 0);
    public int BasisX = 1;
    public int BasisY = 1;
    public int BasisZ = 1;


    public void CreateGrid(int sizeX, int sizeY, int sizeZ)
    {
        // Origin
        CreatePoint("Origin", Origin);

        // Axes
        CreateAxisLine("X", new Vector3(-sizeX, 0, 0), new Vector3(sizeX, 0, 0));
        CreateAxisLine("Y", new Vector3(0, -sizeY, 0), new Vector3(0, sizeY, 0));

        // X Grid Lines
        for (int i = 1; i <= sizeX; i += BasisX)
        {
            CreateGridLine(new Vector3(i, -sizeY, 0), new Vector3(i, sizeY, 0));
            CreateGridLine(new Vector3(-i, -sizeY, 0), new Vector3(-i, sizeY, 0));
        }

        // Y Grid Lines
        for (int i = 1; i <= sizeY; i += BasisY)
        {
            CreateGridLine(new Vector3(-sizeX, i, 0), new Vector3(sizeX, i, 0));
            CreateGridLine(new Vector3(-sizeX, -i, 0), new Vector3(sizeX, -i, 0));
        }
    }

    private Line3D CreateAxisLine(string axisType, Vector3 A, Vector3 B)
    {
        PackedScene scene = null;
        string name = "";
        if (axisType == "X")
        {
            scene = GD.Load<PackedScene>("res://3D/Grid/Scenes/Coordinate Plane/XAxisLine.tscn");
            name = "X Axis";
        }
        else if (axisType == "Y")
        {
            scene = GD.Load<PackedScene>("res://3D/Grid/Scenes/Coordinate Plane/YAxisLine.tscn");
            name = "Y Axis";
        }
        Line3D L = scene.Instantiate<Line3D>();
        L.Name = name;

        LineCalculations(L, A, B);

        GetNode<Node>("Axis").AddChild(L);
        return L;
    }

    private Line3D CreateGridLine(Vector3 A, Vector3 B)
    {
        Vector3 AB = B - A;
        float theta = Mathf.Atan2(AB.X, AB.Y);

        PackedScene scene = GD.Load<PackedScene>("res://3D/Grid/Scenes/Coordinate Plane/GridLine.tscn");
        Line3D L = scene.Instantiate<Line3D>();
        L.Name = "L" + AB.ToString();

        LineCalculations(L, A, B);

        GetNode<Node>("GridLines").AddChild(L);
        return L;
    }

    public Point3D CreatePoint(string name, Vector3 pos)
    {

        PackedScene scene = GD.Load<PackedScene>("res://3D/Grid/Scenes/Point.tscn");
        Point3D P = scene.Instantiate<Point3D>();
        P.Name = name;
        P.Position = pos;

        GetNode<Node>("Points").AddChild(P);
        return P;
    }

    public Line3D CreateLine(string name, Vector3 A, Vector3 B)
    {

        PackedScene scene = GD.Load<PackedScene>("res://3D/Grid/Scenes/Line.tscn");
        Line3D L = scene.Instantiate<Line3D>();
        L.Name = name;

        LineCalculations(L, A, B);

        GetNode<Node>("Lines").AddChild(L);
        return L;
    }

    private void LineCalculations(Line3D L, Vector3 A, Vector3 B)
    {
        Vector3 AB = B - A;

        L.Position = (A + B) / 2;

        L.Scale = new Vector3(0.15f, AB.Length(), 0.15f);


        float theta = Mathf.Atan2(AB.X, AB.Y);
        L.Rotation = new Vector3(0, 0, -theta);
    }
}
