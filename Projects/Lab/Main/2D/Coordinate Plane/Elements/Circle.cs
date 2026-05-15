using Godot;
using System;
using System.Collections.Generic;
using System.Diagnostics;

public partial class Circle : Node2D
{
    public enum CalculationModes
    {
        Area,
        Radius,
        Circumference,
        Color,
    }

    [Export] CalculationModes CalculationMode;
    [Export] public float OriginX;
    [Export] public float OriginY;

    [Export] public float Radius { get; set => SetProperty<float>(ref field, value, CalculationModes.Radius); }
    [Export] public float Area { get; set => SetProperty<float>(ref field, value, CalculationModes.Area); }
    [Export] public float Circumference { get; set => SetProperty<float>(ref field, value, CalculationModes.Circumference); }

    [Export] public string CircleName;
    [Export] public Color Color { get; set => SetProperty<Color>(ref field, value, CalculationModes.Color); }

    private Point[] Points = new Point[360];
    private Point OriginPoint;
    private bool Recalculating;

    public static Circle Create(string name = default, Color color = default, Node parent = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/Circle.tscn");
        Circle circle = scene.Instantiate<Circle>();

        circle.CircleName = name == default ? "Line Segment" : name;
        circle.Color = color == default ? Colors.White : color;
        parent = parent == default ? CartesianPlane.Plane.GetNodeOrNull<Node2D>("Content/Circles") : parent;

        circle.OriginPoint = Point.Create(new MathVector2(0, 0), "Origin Point", circle.Color, circle);
        for (int i = 0; i < circle.Points.Length; i += 1)
        {
            Point point = Point.Create(new MathVector2(0, 0), default, circle.Color, circle);
            circle.Points[i] = point;
        }

        parent.AddChild(circle);
        return circle;
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
            case CalculationModes.Color:
                break;
            case CalculationModes.Radius:
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
        Circumference = 2 * Mathf.Pi * Radius;
        Area = Mathf.Pi * Mathf.Pow(Radius, 2);
        Recalculating = false;

        for (int i = 0; i < Points.Length; i++)
        {
            Points[i].Color = Color;
            Points[i].X = Radius * Mathf.Cos(Mathf.DegToRad(i)) + OriginX;
            Points[i].Y = Radius * Mathf.Sin(Mathf.DegToRad(i)) + OriginY;
        }
    }

    public override void _Process(double delta)
    {
        Name = CircleName;
        Position = Converter.VectorMathToRender(new MathVector2(OriginX, OriginY));
    }
}
