using Godot;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO.Pipes;
using System.Threading;

public partial class StraightLine : Node2D
{
    public enum CalculationModes
    {
        Direction,
        Angle,
        AngleRad,
        Slope,
    }
    [Export] public CalculationModes CalculationMode;
    [Export] public float OriginX { get; set => SetProperty<float>(ref field, value, CalculationModes.Direction); }
    [Export] public float OriginY { get; set => SetProperty<float>(ref field, value, CalculationModes.Direction); }
    [Export] public float DirectionX { get; set => SetProperty<float>(ref field, value, CalculationModes.Direction); }
    [Export] public float DirectionY { get; set => SetProperty<float>(ref field, value, CalculationModes.Direction); }

    [Export] public float Angle { get; set => SetProperty<float>(ref field, value, CalculationModes.Angle); }
    [Export] public float AngleRad { get; set => SetProperty<float>(ref field, value, CalculationModes.AngleRad); }
    [Export] public float Slope { get; set => SetProperty<float>(ref field, value, CalculationModes.Slope); }

    [Export] public string LineName;
    [Export] public Color Color;

    public MathVector2 AB;

    private bool Recalculating = false;
    private MeshInstance2D Arrow1;
    private MeshInstance2D Arrow2;
    private MeshInstance2D LineMesh;
    private Point OriginPoint;

    public static StraightLine Create(string name = default, Color color = default, Node parent = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/StraightLine.tscn");
        StraightLine strLine = scene.Instantiate<StraightLine>();

        strLine.LineMesh = strLine.GetNode<MeshInstance2D>("Line/LineMesh");
        strLine.Arrow1 = strLine.GetNode<MeshInstance2D>("Arrow1/Arrow1Mesh");
        strLine.Arrow2 = strLine.GetNode<MeshInstance2D>("Arrow2/Arrow2Mesh");

        strLine.LineName = name == default ? "Straight Line" : name;
        strLine.Color = color == default ? Colors.White : color;
        parent = parent == default ? CartesianPlane.Plane.GetNode<Node2D>("Content/StraightLines") : parent;

        strLine.OriginPoint = Point.Create(new MathVector2(0, 0), "Origin Point", strLine.Color, strLine);

        parent.AddChild(strLine);
        return strLine;
    }

    public void SetProperty<T>(ref T propertyRef, T value, CalculationModes mode)
    {
        if (!EqualityComparer<T>.Default.Equals(propertyRef, value))
        {
            propertyRef = value;
            if (Recalculating == false)
            {
                CalculationMode = mode;
                Recalculating = true;
                Recalculate();
            }
        }
    }
    public void Recalculate()
    {
        switch (CalculationMode)
        {
            case CalculationModes.Direction:
                break;
            case CalculationModes.AngleRad:
                DirectionX = OriginX + Mathf.Cos(AngleRad);
                DirectionY = OriginY + Mathf.Sin(AngleRad);
                break;
            case CalculationModes.Angle:
                DirectionX = OriginX + Mathf.Cos(Mathf.DegToRad(Angle));
                DirectionY = OriginY + Mathf.Sin(Mathf.DegToRad(Angle));
                break;
            case CalculationModes.Slope:
                DirectionX = OriginX + Mathf.Cos(Mathf.Atan(Slope));
                DirectionY = OriginY + Mathf.Sin(Mathf.Atan(Slope));
                break;
            default:
                break;
        }
        AB = new MathVector2(DirectionX - OriginX, DirectionY - OriginY);
        AngleRad = Mathf.Atan2(AB.Y, AB.X);
        Angle = Mathf.RadToDeg(AngleRad);
        Slope = AB.Y / AB.X;
        Recalculating = false;
    }

    public override void _Process(double delta)
    {
        Position = Converter.VectorMathToRender(new MathVector2(OriginX, OriginY));
        Rotation = Converter.AngleMathToRender(Mathf.Atan2(AB.Y, AB.X));

        GetNode<Node2D>("Line").Scale = new Vector2(CartesianPlane.Size * 2, 0.5f);
        GetNode<Node2D>("Arrow1").Position = new Vector2(-GetNode<Node2D>("Line").Scale.X / 2, 0);
        GetNode<Node2D>("Arrow2").Position = new Vector2(GetNode<Node2D>("Line").Scale.X / 2, 0);

        LineMesh.Modulate = Color;
        Arrow1.Modulate = Color;
        Arrow2.Modulate = Color;
    }
}
