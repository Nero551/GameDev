using Godot;
using System;

public partial class Rhombus : Quadrilateral<Rhombus.CalculationModes>
{
    public enum CalculationModes
    {
        Origin,
        SideLength,
        DiagonalLength,
        Perimeter,
        Area,
        Color,
    }

    [Export] public float OriginX { get; set => SetProperty<float>(ref field, value, CalculationModes.Origin); }
    [Export] public float OriginY { get; set => SetProperty<float>(ref field, value, CalculationModes.Origin); }
    [Export] public float SideLength { get; set => SetProperty<float>(ref field, value, CalculationModes.SideLength); }
    [Export] public float DiagonalLength { get; set => SetProperty<float>(ref field, value, CalculationModes.DiagonalLength); }
    [Export] public float Perimeter { get; set => SetProperty<float>(ref field, value, CalculationModes.Perimeter); }
    [Export] public float Area { get; set => SetProperty<float>(ref field, value, CalculationModes.Area); }
    [Export] public float Orientation;

    //* A is the Origin.
    private MathVector2 B;
    private MathVector2 C;
    private MathVector2 D;

    private LineSegment AB;
    private LineSegment BC;
    private LineSegment CD;
    private LineSegment AD;

    //Diagonals
    // private LineSegment AC;
    // private LineSegment BD;

    [Export] public string RhombusName;
    [Export] public Color Color { get; set => SetProperty<Color>(ref field, value, CalculationModes.Color); }

    public static Rhombus Create(string name = default, Color color = default, Node parent = default)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/2D/Coordinate Plane/Scenes/Square.tscn");
        Rhombus rhombus = scene.Instantiate<Rhombus>();

        rhombus.RhombusName = name == default ? "Square" : name;
        rhombus.Color = color == default ? Colors.White : color;
        parent = parent == default ? CartesianPlane.Plane.GetNodeOrNull<Node2D>("Content/Squares") : parent;

        rhombus.AB = LineSegment.Create("AB", rhombus.Color, rhombus);
        rhombus.BC = LineSegment.Create("BC", rhombus.Color, rhombus);
        rhombus.CD = LineSegment.Create("CD", rhombus.Color, rhombus);
        rhombus.AD = LineSegment.Create("AD", rhombus.Color, rhombus);


        //Diagonals
        // square.AC = LineSegment.Create("AC", square.Color, square);
        // square.BD = LineSegment.Create("BD", square.Color, square);

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

    public override void Recalculate()
    {
        switch (CalculationMode)
        {
            case CalculationModes.Origin:
                break;
            case CalculationModes.Color:
                break;
            case CalculationModes.SideLength:
                break;
            case CalculationModes.DiagonalLength:
                SideLength = DiagonalLength / Mathf.Sqrt(2);
                break;
            case CalculationModes.Perimeter:
                SideLength = Perimeter / 4;
                break;
            case CalculationModes.Area:
                SideLength = Mathf.Sqrt(Area);
                break;
            default:
                break;
        }
        DiagonalLength = SideLength * Mathf.Sqrt(2);
        Perimeter = 4 * SideLength;
        Area = Mathf.Pow(SideLength, 2);

        B = new MathVector2(SideLength, 0);
        C = new MathVector2(B.X, B.Y + SideLength);
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
        Name = RhombusName;
    }
}
