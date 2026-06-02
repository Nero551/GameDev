using Godot;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO.Pipes;
using System.Threading;

public partial class StraightLine : Element<StraightLine.CalculationModes>
{
    public enum CalculationModes
    {
        Direction,
        Angle,
        AngleRad,
        Slope,
    }
    [Export] public float OriginX { get; set => SetProperty<float>(ref field, value, CalculationModes.Direction); }
    [Export] public float OriginY { get; set => SetProperty<float>(ref field, value, CalculationModes.Direction); }
    [Export] public float DirectionX { get; set => SetProperty<float>(ref field, value, CalculationModes.Direction); }
    [Export] public float DirectionY { get; set => SetProperty<float>(ref field, value, CalculationModes.Direction); }

    [Export] public float Angle { get; set => SetProperty<float>(ref field, value, CalculationModes.Angle); }
    [Export] public float AngleRad { get; set => SetProperty<float>(ref field, value, CalculationModes.AngleRad); }
    [Export] public float Slope { get; set => SetProperty<float>(ref field, value, CalculationModes.Slope); }

    [Export] public Color Color;

    private MathVector2 AB;
    private Point OriginPoint;

    public static StraightLine Create(string name = default, Color color = default, Node parent = default)
    {
        PackedScene scene = SceneLoader.Load("StraightLine");
        StraightLine strLine = scene.Instantiate<StraightLine>();

        strLine.ElementName = name == default ? "Straight Line" : name;
        strLine.Color = color == default ? Colors.White : color;
        parent = parent == default ? CartesianPlane.Plane.GetNode<Node2D>("Content/StraightLines") : parent;

        strLine.OriginPoint = Point.Create(new MathVector2(0, 0), "Origin Point", strLine.Color, strLine);

        parent.AddChild(strLine);
        return strLine;
    }

    protected override void Recalculate()
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

        Position = Converter.VectorMathToRender(new MathVector2(OriginX, OriginY));
        Rotation = Converter.AngleMathToRender(Mathf.Atan2(AB.Y, AB.X));
        GetNode<Node2D>("Line").Scale = new Vector2(CartesianPlane.Size * 2, 0.5f);

        GetNode<Node2D>("Arrow1").Position = new Vector2(-GetNode<Node2D>("Line").Scale.X / 2, 0);
        GetNode<Node2D>("Arrow2").Position = new Vector2(GetNode<Node2D>("Line").Scale.X / 2, 0);
        
        Recalculating = false;
    }

    public override void _Process(double delta)
    {
        Name = ElementName;
        GetNode<MeshInstance2D>("Line/LineMesh").Modulate = Color;
        GetNode<MeshInstance2D>("Arrow1/Arrow1Mesh").Modulate = Color;
        GetNode<MeshInstance2D>("Arrow2/Arrow2Mesh").Modulate = Color;
        OriginPoint.Color = Color;
    }
}
