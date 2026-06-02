using Godot;
using System;

public partial class Parallelogram : Quadrilateral<Parallelogram.CalculationModes>
{
    public enum CalculationModes
    {
        Origin,
        Width,
        Length,
        Diagonal1Length,
        Diagonal2Length,
        Perimeter,
        Area,
        Color,
        Angle
    }

    [Export] public float OriginX { get; set => SetProperty<float>(ref field, value, CalculationModes.Origin); }
    [Export] public float OriginY { get; set => SetProperty<float>(ref field, value, CalculationModes.Origin); }
    [Export] public float Width { get; set => SetProperty<float>(ref field, value, CalculationModes.Width); }
    [Export] public float Length { get; set => SetProperty<float>(ref field, value, CalculationModes.Length); }
    [Export] public float Diagonal1Length { get; set => SetProperty<float>(ref field, value, CalculationModes.Diagonal1Length); }
    [Export] public float Diagonal2Length { get; set => SetProperty<float>(ref field, value, CalculationModes.Diagonal2Length); }
    [Export] public float Perimeter { get; set => SetProperty<float>(ref field, value, CalculationModes.Perimeter); }
    [Export] public float Area { get; set => SetProperty<float>(ref field, value, CalculationModes.Area); }
    [Export] public float Angle { get; set => SetProperty<float>(ref field, value, CalculationModes.Angle); }
    [Export] public float Orientation;

    [Export] public Color Color { get; set => SetProperty<Color>(ref field, value, CalculationModes.Color); }

    public static Parallelogram Create(string name = default, Color color = default, Node parent = default)
    {
        PackedScene scene = SceneLoader.Load("Parallelogram");
        Parallelogram parallelogram = scene.Instantiate<Parallelogram>();

        parallelogram.ElementName = name == default ? "Parallelogram" : name;
        parallelogram.Color = color == default ? Colors.White : color;
        parent = parent == default ? CartesianPlane.Plane.GetNodeOrNull<Node2D>("Content/Parallelograms") : parent;

        parallelogram.AB = LineSegment.Create("AB", parallelogram.Color, parallelogram);
        parallelogram.BC = LineSegment.Create("BC", parallelogram.Color, parallelogram);
        parallelogram.CD = LineSegment.Create("CD", parallelogram.Color, parallelogram);
        parallelogram.AD = LineSegment.Create("AD", parallelogram.Color, parallelogram);

        // Diagonals
        parallelogram.AC = LineSegment.Create("AC", parallelogram.Color, parallelogram);
        parallelogram.BD = LineSegment.Create("BD", parallelogram.Color, parallelogram);

        parent.AddChild(parallelogram);
        return parallelogram;
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
        //* if both Length and Width are unknown, it assumes Length = 2 Width.
        switch (CalculationMode)
        {
            case CalculationModes.Angle:
                break;
            case CalculationModes.Origin:
                break;
            case CalculationModes.Color:
                break;
            case CalculationModes.Length:
                break;
            case CalculationModes.Width:
                break;
            // case CalculationModes.DiagonalLength:
            //     Width = DiagonalLength / Mathf.Sqrt(5);
            //     Length = 2 * Width;
            //     break;
            // case CalculationModes.Perimeter:
            //     Width = Perimeter / 6;
            //     Length = 2 * Width;
            //     break;
            // case CalculationModes.Area:
            //     Width = Mathf.Sqrt(Area / 2);
            //     Length = 2 * Width;
            //     break;
            default:
                break;
        }
        Diagonal1Length = (float)Mathf.Sqrt(Mathf.Pow(Width * Mathf.Sin(Angle), 2) +
                         Mathf.Pow(Length + Width * Mathf.Cos(Angle), 2));
        Diagonal1Length = (float)Mathf.Sqrt(Mathf.Pow(Width * Mathf.Sin(Angle), 2) +
                        Mathf.Pow(Length - Width * Mathf.Cos(Angle), 2));
        // Perimeter = 2 * (Width + Length);
        // Area = Width * Length;

        B = new MathVector2(Length, 0);
        C = new MathVector2(
            B.X + Mathf.Cos(Mathf.DegToRad(Angle)) * Width,
             B.Y + (Width * Mathf.Sin(Mathf.DegToRad(Angle)))
            );
        D = new MathVector2(C.X - B.X, C.Y - B.Y);

        // Diagonals
        Set(AC, new MathVector2(0, 0), C);
        Set(BD, B, D);

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
