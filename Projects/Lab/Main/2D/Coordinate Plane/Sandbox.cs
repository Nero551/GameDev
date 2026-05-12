using Godot;
using System;

public partial class CartesianPlane
{
    public void Sandbox()
    {
        Circle(Vector2(0, 0), 5);
        LineSegment(Vector2(-6, 5), Vector2(-8, 3), Colors.Crimson);
        StraightLine strL = StraightLine(Origin, Vector2(5, 5), Colors.White);
        StraightLine strL2 = StraightLine(Origin, -1/strL.Slope , Colors.Red);
        // StraightLine(Origin, 1, Colors.White);
        Ray(Origin, Vector2(-3, 2), Colors.Pink);
    }
}
