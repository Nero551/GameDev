using Godot;
using System;
using System.Collections.Generic;

public partial class Ray : Element<Ray.CalculationModes>
{
    public enum CalculationModes
    {
        Direction,
        Angle,
        AngleRad,
        Slope,
        Length
    }
    [Export] public float OriginX { get; set => SetProperty<float>(ref field, value, CalculationModes.Direction); }
    [Export] public float OriginY { get; set => SetProperty<float>(ref field, value, CalculationModes.Direction); }
    [Export] public float DirectionX { get; set => SetProperty<float>(ref field, value, CalculationModes.Direction); }
    [Export] public float DirectionY { get; set => SetProperty<float>(ref field, value, CalculationModes.Direction); }

    [Export] public float Length { get; set => SetProperty<float>(ref field, value, CalculationModes.Length); }
    [Export] public float Angle { get; set => SetProperty<float>(ref field, value, CalculationModes.Angle); }
    [Export] public float AngleRad { get; set => SetProperty<float>(ref field, value, CalculationModes.AngleRad); }
    [Export] public float Slope { get; set => SetProperty<float>(ref field, value, CalculationModes.Slope); }

    [Export] public Color Color;

    private MathVector2 AB;
    private Point OriginPoint;

    public static Ray Create(string name = default, Color color = default, Node parent = default)
    {
        PackedScene scene = SceneLoader.Load("Ray");
        Ray ray = scene.Instantiate<Ray>();

        ray.ElementName = name == default ? "Ray" : name;
        ray.Color = color == default ? Colors.White : color;
        parent = parent == default ? CartesianPlane.Plane.GetNodeOrNull<Node2D>("Content/Rays") : parent;

        ray.OriginPoint = Point.Create(new MathVector2(0, 0), "Origin Point", ray.Color, ray);
        parent.AddChild(ray);
        return ray;
    }

    protected override void Recalculate()
    {
        switch (CalculationMode)
        {
            case CalculationModes.Direction:
                break;
            case CalculationModes.AngleRad:
                DirectionX = OriginX + Length * Mathf.Cos(AngleRad);
                DirectionY = OriginY + Length * Mathf.Sin(AngleRad);
                break;
            case CalculationModes.Angle:
                DirectionX = OriginX + Length * Mathf.Cos(Mathf.DegToRad(Angle));
                DirectionY = OriginY + Length * Mathf.Sin(Mathf.DegToRad(Angle));
                break;
            case CalculationModes.Slope:
                DirectionX = OriginX + Length * Mathf.Cos(Mathf.Atan(Slope));
                DirectionY = OriginY + Length * Mathf.Sin(Mathf.Atan(Slope));
                break;
            case CalculationModes.Length:
                DirectionX = OriginX + Length * Mathf.Cos(AngleRad);
                DirectionY = OriginY + Length * Mathf.Sin(AngleRad);
                break;
            default:
                break;
        }
        AB = new MathVector2(DirectionX - OriginX, DirectionY - OriginY);
        Length = AB.Length();
        AngleRad = Mathf.Atan2(AB.Y, AB.X);
        Angle = Mathf.RadToDeg(AngleRad);
        Slope = AB.Y / AB.X;

        Position = Converter.VectorMathToRender(new MathVector2(OriginX, OriginY));
        Rotation = Converter.AngleMathToRender(Mathf.Atan2(AB.Y, AB.X));
        GetNode<Node2D>("Line").Scale = new Vector2(Converter.LengthMathToRender(AB.Length()), 0.5f);
        GetNode<Node2D>("Arrow").Position = new Vector2(GetNode<Node2D>("Line").Scale.X, 0);

        Recalculating = false;
    }

    public override void _Process(double delta)
    {
        Name = ElementName;
        GetNode<MeshInstance2D>("Line/LineMesh").Modulate = Color;
        GetNode<MeshInstance2D>("Arrow/ArrowMesh").Modulate = Color;
        OriginPoint.Color = Color;
    }
}
