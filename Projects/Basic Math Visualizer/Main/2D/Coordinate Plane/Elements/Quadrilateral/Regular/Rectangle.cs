using Godot;
using System;

public partial class Rectangle : Quadrilateral<Rectangle.CalculationModes>
{
    public enum CalculationModes
    {
        Origin,
        Width,
        Length,
        DiagonalLength,
        Perimeter,
        Area,
        Color,
    }

    [Export] public float OriginX { get; set => SetProperty<float>(ref field, value, CalculationModes.Origin); }
    [Export] public float OriginY { get; set => SetProperty<float>(ref field, value, CalculationModes.Origin); }
    [Export] public float Width { get; set => SetProperty<float>(ref field, value, CalculationModes.Width); }
    [Export] public float Length { get; set => SetProperty<float>(ref field, value, CalculationModes.Length); }
    [Export] public float DiagonalLength { get; set => SetProperty<float>(ref field, value, CalculationModes.DiagonalLength); }
    [Export] public float Perimeter { get; set => SetProperty<float>(ref field, value, CalculationModes.Perimeter); }
    [Export] public float Area { get; set => SetProperty<float>(ref field, value, CalculationModes.Area); }
    [Export] public float Orientation;

    [Export] public Color Color { get; set => SetProperty<Color>(ref field, value, CalculationModes.Color); }

    public static Rectangle Create(string name = default, Color color = default, Node parent = default)
    {
        PackedScene scene = SceneLoader.Load("Rectangle");
        Rectangle rectangle = scene.Instantiate<Rectangle>();

        rectangle.ElementName = name == default ? "Rectangle" : name;
        rectangle.Color = color == default ? Colors.White : color;
        parent = parent == default ? CartesianPlane.Plane.GetNodeOrNull<Node2D>("Content/Rectangles") : parent;

        rectangle.AB = LineSegment.Create("AB", rectangle.Color, rectangle);
        rectangle.BC = LineSegment.Create("BC", rectangle.Color, rectangle);
        rectangle.CD = LineSegment.Create("CD", rectangle.Color, rectangle);
        rectangle.AD = LineSegment.Create("AD", rectangle.Color, rectangle);


        // Diagonals
        // rectangle.AC = LineSegment.Create("AC", rectangle.Color, rectangle);
        // rectangle.BD = LineSegment.Create("BD", rectangle.Color, rectangle);

        parent.AddChild(rectangle);
        return rectangle;
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
            case CalculationModes.Origin:
                break;
            case CalculationModes.Color:
                break;
            case CalculationModes.Length:
                break;
            case CalculationModes.Width:
                break;
            case CalculationModes.DiagonalLength:
                Width = DiagonalLength / Mathf.Sqrt(5);
                Length = 2 * Width;
                break;
            case CalculationModes.Perimeter:
                Width = Perimeter / 6;
                Length = 2 * Width;
                break;
            case CalculationModes.Area:
                Width = Mathf.Sqrt(Area / 2);
                Length = 2 * Width;
                break;
            default:
                break;
        }
        DiagonalLength = Mathf.Sqrt(Mathf.Pow(Length, 2) + Mathf.Pow(Width, 2));
        Perimeter = 2 * (Width + Length);
        Area = Width * Length;

        B = new MathVector2(Length, 0);
        C = new MathVector2(B.X, B.Y + Width);
        D = new MathVector2(0, C.Y);

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
