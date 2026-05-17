using Godot;
using System;

public partial class Rhombus : Quadrilateral<Rhombus.CalculationModes>
{
    public enum CalculationModes
    {
        Origin,
        SideLength,
        VerticalDiagonalLength,
        HorizontalDiagonalLength,
        Angle,
        Perimeter,
        Area,
        Color,
    }

    [Export] public float OriginX { get; set => SetProperty<float>(ref field, value, CalculationModes.Origin); }
    [Export] public float OriginY { get; set => SetProperty<float>(ref field, value, CalculationModes.Origin); }
    [Export] public float SideLength { get; set => SetProperty<float>(ref field, value, CalculationModes.SideLength); }
    [Export] public float VerticalDiagonalLength { get; set => SetProperty<float>(ref field, value, CalculationModes.VerticalDiagonalLength); }
    [Export] public float HorizontalDiagonalLength { get; set => SetProperty<float>(ref field, value, CalculationModes.HorizontalDiagonalLength); }
    [Export] public float Perimeter { get; set => SetProperty<float>(ref field, value, CalculationModes.Perimeter); }
    [Export] public float Area { get; set => SetProperty<float>(ref field, value, CalculationModes.Area); }
    [Export] public float Angle { get; set => SetProperty<float>(ref field, value, CalculationModes.Angle); }
    [Export] public float Orientation;

    [Export] public Color Color { get; set => SetProperty<Color>(ref field, value, CalculationModes.Color); }

    public static Rhombus Create(string name = default, Color color = default, Node parent = default)
    {
        PackedScene scene = SceneLoader.Load("Rhombus");
        Rhombus rhombus = scene.Instantiate<Rhombus>();

        rhombus.ElementName = name == default ? "Rhombus" : name;
        rhombus.Color = color == default ? Colors.White : color;
        parent = parent == default ? CartesianPlane.Plane.GetNodeOrNull<Node2D>("Content/Rhombuses") : parent;

        rhombus.AB = LineSegment.Create("AB", rhombus.Color, rhombus);
        rhombus.BC = LineSegment.Create("BC", rhombus.Color, rhombus);
        rhombus.CD = LineSegment.Create("CD", rhombus.Color, rhombus);
        rhombus.AD = LineSegment.Create("AD", rhombus.Color, rhombus);

        //Diagonals
        // rhombus.AC = LineSegment.Create("AC", rhombus.Color, rhombus);
        // rhombus.BD = LineSegment.Create("BD", rhombus.Color, rhombus);

        parent.AddChild(rhombus);
        return rhombus;
    }

    private void Set(LineSegment side, MathVector2 a, MathVector2 b)
    {
        side?.Color = Color;
        side?.AX = a.X;
        side?.AY = a.Y;
        side?.BX = b.X;
        side?.BY = b.Y;
    }

    protected override void Recalculate()
    {
        //* if both side and angle are unknown, it assumes Angle  = 45
        switch (CalculationMode)
        {
            case CalculationModes.Origin:
                break;
            case CalculationModes.Color:
                break;
            case CalculationModes.SideLength:
                break;
            case CalculationModes.Angle:
                break;
            case CalculationModes.VerticalDiagonalLength:
                VerticalDiagonalLength = Mathf.Clamp(VerticalDiagonalLength, -SideLength * 2, SideLength * 2);
                Angle = 2 * Mathf.RadToDeg(Mathf.Acos(VerticalDiagonalLength / 2 / SideLength));
                break;
            case CalculationModes.HorizontalDiagonalLength:
                HorizontalDiagonalLength = Mathf.Clamp(HorizontalDiagonalLength, -SideLength * 2, SideLength * 2);
                Angle = 2 * Mathf.RadToDeg(Mathf.Asin(HorizontalDiagonalLength / 2 / SideLength));
                break;
            case CalculationModes.Perimeter:
                SideLength = Perimeter / 4;
                break;
            case CalculationModes.Area:
                SideLength = Mathf.Abs(Mathf.Sqrt(Area / Mathf.Sin(Mathf.DegToRad(Angle))));
                break;
            default:
                break;
        }
        VerticalDiagonalLength = 2 * SideLength * Mathf.Cos(Mathf.DegToRad(Angle / 2));
        HorizontalDiagonalLength = 2 * SideLength * Mathf.Sin(Mathf.DegToRad(Angle / 2));
        Perimeter = 4 * SideLength;
        Area = Mathf.Abs(Mathf.Pow(SideLength, 2) * Mathf.Sin(Angle));

        B = new MathVector2(
             SideLength * Mathf.Cos(Mathf.DegToRad((180 - Angle) / 2)),
              SideLength * Mathf.Sin(Mathf.DegToRad((180 - Angle) / 2))
            );
        D = new MathVector2(
             SideLength * Mathf.Cos(Mathf.DegToRad(180 - (180 - Angle) / 2)),
             SideLength * Mathf.Sin(Mathf.DegToRad(180 - (180 - Angle) / 2))
            );

        C = B + D;

        //Diagonals
        // Set(AC, new MathVector2(0, 0), C);
        // Set(BD, B, D);

        //Sides
        Set(AB, new MathVector2(0, 0), B);
        Set(BC, B, C);
        Set(CD, C, D);
        Set(AD, new MathVector2(0, 0), D);

        Position = Converter.VectorMathToRender(new MathVector2(OriginX, OriginY));
        Recalculating = false;
    }

    public override void _Process(double delta)
    {
        Rotation = Converter.AngleMathToRender(Mathf.DegToRad(Orientation));
        Name = ElementName;
    }
}
