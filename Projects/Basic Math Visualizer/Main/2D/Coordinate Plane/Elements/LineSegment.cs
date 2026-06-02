using Godot;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;

public partial class LineSegment : Element<LineSegment.CalculationModes>
{
    public enum CalculationModes
    {
        Point,
        Angle,
        AngleRad,
        Slope,
        Length
    }
    [Export] public float AX { get; set => SetProperty<float>(ref field, value, CalculationModes.Point); }
    [Export] public float AY { get; set => SetProperty<float>(ref field, value, CalculationModes.Point); }
    [Export] public float BX { get; set => SetProperty<float>(ref field, value, CalculationModes.Point); }
    [Export] public float BY { get; set => SetProperty<float>(ref field, value, CalculationModes.Point); }

    [Export] public float Length { get; set => SetProperty<float>(ref field, value, CalculationModes.Length); }
    [Export] public float Angle { get; set => SetProperty<float>(ref field, value, CalculationModes.Angle); }
    [Export] public float AngleRad { get; set => SetProperty<float>(ref field, value, CalculationModes.AngleRad); }
    [Export] public float Slope { get; set => SetProperty<float>(ref field, value, CalculationModes.Slope); }

    [Export] public Color Color;
    
    private MathVector2 AB;

    public static LineSegment Create(string name = default, Color color = default, Node parent = default)
    {
        PackedScene scene = SceneLoader.Load("LineSegment");
        LineSegment line = scene.Instantiate<LineSegment>();

        line.ElementName = name == default ? "Line Segment" : name;
        line.Color = color == default ? Colors.White : color;
        parent = parent == default ? CartesianPlane.Plane.GetNodeOrNull<Node2D>("Content/LineSegments") : parent;

        parent.AddChild(line);
        return line;
    }

    protected override void Recalculate()
    {
        switch (CalculationMode)
        {
            case CalculationModes.Point:
                break;
            case CalculationModes.AngleRad:
                BX = AX + Length * Mathf.Cos(AngleRad);
                BY = AY + Length * Mathf.Sin(AngleRad);
                break;
            case CalculationModes.Angle:
                BX = AX + Length * Mathf.Cos(Mathf.DegToRad(Angle));
                BY = AY + Length * Mathf.Sin(Mathf.DegToRad(Angle));
                break;
            case CalculationModes.Slope:
                BX = AX + Length * Mathf.Cos(Mathf.Atan(Slope));
                BY = AY + Length * Mathf.Sin(Mathf.Atan(Slope));
                break;
            case CalculationModes.Length:
                BX = AX + Length * Mathf.Cos(AngleRad);
                BY = AY + Length * Mathf.Sin(AngleRad);
                break;
            default:
                break;
        }
        AB = new MathVector2(BX - AX, BY - AY);
        Length = AB.Length();
        AngleRad = Mathf.Atan2(AB.Y, AB.X);
        Angle = Mathf.RadToDeg(AngleRad);
        Slope = AB.Y / AB.X;

        Scale = new Vector2(Converter.LengthMathToRender(AB.Length()), 0.5f);
        Position = Converter.VectorMathToRender(new MathVector2(AX + BX, AY + BY) / 2);
        Rotation = Converter.AngleMathToRender(Mathf.Atan2(AB.Y, AB.X));

        Recalculating = false;
    }

    public override void _Process(double delta)
    {
        Name = ElementName;
        GetNode<MeshInstance2D>("Line").Modulate = Color;
    }
}
