using Godot;
using Godot.NativeInterop;
using System;

public partial class CartesianPlane
{
    public void Sandbox()
    {
        MathVector2 A = new MathVector2(3, 1);
        MathVector2 B = new MathVector2(-5, 5);
        // Point.Create(B, "B");
        // LineSegment line = LineSegment.Create("AB", Colors.Blue);
        // line.AX = 0;
        // line.AY = 0;
        // line.BY = 5;
        // line.BX = 5;
        // StraightLine.Create("C", Colors.White);
        Ray.Create("A", Colors.Blue);
    }
}
