using Godot;
using System;
using System.Collections.Generic;
using System.Diagnostics;

public partial class Circle : Element<Circle.CalculationModes>
{
    public enum CalculationModes
    {
        Diameter,
        Area,
        Radius,
        Circumference,
        Color,
    }
    [Export] public float OriginX;
    [Export] public float OriginY;

    [Export] public float Radius { get; set => SetProperty<float>(ref field, value, CalculationModes.Radius); }
    [Export] public float Diameter { get; set => SetProperty<float>(ref field, value, CalculationModes.Diameter); }
    [Export] public float Area { get; set => SetProperty<float>(ref field, value, CalculationModes.Area); }
    [Export] public float Circumference { get; set => SetProperty<float>(ref field, value, CalculationModes.Circumference); }

    [Export] public Color Color { get; set => SetProperty<Color>(ref field, value, CalculationModes.Color); }

    private Point[] Points = new Point[360];
    private Point OriginPoint;

    public static Circle Create(string name = default, Color color = default, Node parent = default)
    {
        PackedScene scene = SceneLoader.Load("Circle");
        Circle circle = scene.Instantiate<Circle>();

        circle.ElementName = name == default ? "Circle" : name;
        circle.Color = color == default ? Colors.White : color;
        parent = parent == default ? CartesianPlane.Plane.GetNodeOrNull<Node2D>("Content/Circles") : parent;

        circle.OriginPoint = Point.Create(new MathVector2(0, 0), "Origin Point", circle.Color, circle);
        for (int i = 0; i < circle.Points.Length; i++)
        {
            Point point = Point.Create(new MathVector2(0, 0), default, circle.Color, circle);
            circle.Points[i] = point;
        }

        parent.AddChild(circle);
        return circle;
    }

    protected override void Recalculate()
    {
        switch (CalculationMode)
        {
            case CalculationModes.Color:
                break;
            case CalculationModes.Radius:
                break;
            case CalculationModes.Diameter:
                Radius = Diameter / 2;
                break;
            case CalculationModes.Area:
                Radius = Mathf.Sqrt(Area / Mathf.Pi);
                break;
            case CalculationModes.Circumference:
                Radius = Circumference / 2 / Mathf.Pi;
                break;
            default:
                break;
        }
        Diameter = Radius * 2;
        Circumference = 2 * Mathf.Pi * Radius;
        Area = Mathf.Pi * Mathf.Pow(Radius, 2);
        Recalculating = false;
        
        OriginPoint?.Color = Color;
        for (int i = 0; i < Points.Length; i++)
        {
            Points[i]?.Color = Color;
            Points[i]?.X = Radius * Mathf.Cos(Mathf.DegToRad(i));
            Points[i]?.Y = Radius * Mathf.Sin(Mathf.DegToRad(i));
        }
    }

    public override void _Process(double delta)
    {
        Name = ElementName;
        Position = Converter.VectorMathToRender(new MathVector2(OriginX, OriginY));
    }
}
