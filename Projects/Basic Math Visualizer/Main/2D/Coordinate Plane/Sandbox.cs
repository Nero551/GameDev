using Godot;
using Godot.NativeInterop;
using System;

public partial class CartesianPlane
{
    Sine sine;
    Cosine cosine;
    Tangent tangent;
    public void Sandbox()
    {
        MathVector2 A = new MathVector2(3, 1);
        MathVector2 B = new MathVector2(-5, 5);
        // Point.Create(B, "B");

        // LineSegment line = LineSegment.Create("AB", Colors.Blue);
        // line.AX = -3;
        // line.AY = -5;
        // line.BY = -3;
        // line.BX = -5;

        // StraightLine strLine = StraightLine.Create("C", Colors.White);
        // strLine.OriginX = Origin.X;
        // strLine.OriginY = Origin.Y;
        // strLine.Angle = 135;

        // Ray ray = Ray.Create("A", Colors.Blue);
        // ray.OriginX = Origin.X;
        // ray.OriginY = Origin.Y;
        // ray.DirectionX = 5;
        // ray.DirectionY = 5;

        // Circle circle = Circle.Create("M");
        // circle.Radius = 5;

        // Square square = Square.Create("ABCD");
        // square.OriginX = Origin.X;
        // square.OriginY = Origin.Y;
        // square.SideLength = 5;

        // Rectangle rectangle = Rectangle.Create("ABCD");\
        // rectangle.OriginX = Origin.X;
        // rectangle.OriginY = Origin.Y;
        // rectangle.Length = 10;
        // rectangle.Width = 3;

        // Rhombus rhombus = Rhombus.Create("ABCD");
        // rhombus.OriginX = Origin.X;
        // rhombus.OriginY = Origin.Y;
        // rhombus.SideLength = 5;

        // Parallelogram parallelogram = Parallelogram.Create("ABCD");
        // parallelogram.Width = 5;
        // parallelogram.Length = 8;
        // parallelogram.Angle = 90;

        sine = Sine.Create(default, Colors.Blue);
        cosine = Cosine.Create(default, Colors.Red);
        // sine.Amplitude = 20;
        // cosine.Amplitude = 20;
        // tangent = Tangent.Create(default, Colors.Purple);
    }

    public override void _Process(double delta)
    {
        int multiplier = 5;
        sine.Period += multiplier * (float)delta;
        // tangent.Period += multiplier * (float)delta;
        cosine.Period += multiplier * (float)delta;

        //* Input
        if (Input.IsActionJustPressed("CreateRay"))
        {
            Ray ray = Ray.Create();
            
        }
    }
}
