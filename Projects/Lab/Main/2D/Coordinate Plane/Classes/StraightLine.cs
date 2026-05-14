using Godot;
using System;
using System.Diagnostics;
using System.IO.Pipes;
using System.Threading;

public partial class StraightLine : Node2D
{
    [Export] public float Slope = default;
    [Export] public float Angle = default;
    [Export] public float AngleRad = default;
    [Export] public Color Color = default;
    [Export] public string LineName = default;
    [Export] public Vector2 A = default;
    [Export] public Vector2 B = default;
    [Export] public Vector2 DirectionVector = default;
    
    private MeshInstance2D Arrow1;
    private MeshInstance2D Arrow2;
    private MeshInstance2D LineMesh;
    private double Elapsed = 0;

    public static StraightLine Create(string name, Color color = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/StraightLine.tscn");
        StraightLine strLine = scene.Instantiate<StraightLine>();

        strLine.LineMesh = strLine.GetNode<MeshInstance2D>("Line/LineMesh");
        strLine.Arrow1 = strLine.GetNode<MeshInstance2D>("Arrow1/Arrow1Mesh");
        strLine.Arrow2 = strLine.GetNode<MeshInstance2D>("Arrow2/Arrow2Mesh");

        strLine.LineName = name;
        strLine.Color = color;

        MathWorld.World.GetNodeOrNull<Node2D>("Cartesian Plane/My Stuff").AddChild(strLine);
        return strLine;
    }

    public override void _Process(double delta)
    {
        Elapsed += delta;
        if (Elapsed < 0.1)
        {
            return;
        }
        Elapsed = 0;
        RegisterData();
        GD.Print("3: ", AngleRad);
        Position = (A + B) / 2;
        Rotation = (B - A).Angle();


        GetNode<Node2D>("Line").Scale = new Vector2(CartesianPlane.Size * 2, 0.5f);
        GetNode<Node2D>("Arrow1").Position = new Vector2(-GetNode<Node2D>("Line").Scale.X / 2, 0);
        GetNode<Node2D>("Arrow2").Position = new Vector2(GetNode<Node2D>("Line").Scale.X / 2, 0);

        LineMesh.Modulate = Color == default ? Colors.DimGray : Color;
        Arrow1.Modulate = Color == default ? Colors.DimGray : Color;
        Arrow2.Modulate = Color == default ? Colors.DimGray : Color;
    }

    public void RegisterData()
    {
        if (Slope != default)
        {
            AngleRad = Mathf.Atan(Slope);
            Angle = Mathf.RadToDeg(AngleRad);
            B = A + CartesianPlane.Vector2(Mathf.Cos(AngleRad), Mathf.Sin(AngleRad));
        }
        if (B != default)
        {
            AngleRad = AngleRad = Mathf.Atan2((B - A).Y, (B - A).X);;
            Angle = Mathf.RadToDeg(AngleRad);
            Slope = Mathf.Cos(AngleRad) / Mathf.Sin(AngleRad);
        }
        if (Angle != default)
        {
            AngleRad = Mathf.DegToRad(Angle);
            Slope = Mathf.Tan(AngleRad);
            B = A + CartesianPlane.Vector2(Mathf.Cos(AngleRad), Mathf.Sin(AngleRad));
        }
        if (AngleRad != default)
        {
            Angle = Mathf.RadToDeg(AngleRad);
            Slope = Mathf.Tan(AngleRad);
            B = CartesianPlane.Vector2(Mathf.Cos(AngleRad), Mathf.Sin(AngleRad));
        }

        var meshInstance = this.GetNode<MeshInstance2D>("Line/LineMesh");
        Color = meshInstance.Modulate;
        LineName = this.Name;
        // DirectionVector = new Vector2(Mathf.Cos(AngleRad), Mathf.Sin(AngleRad));
    }
}
