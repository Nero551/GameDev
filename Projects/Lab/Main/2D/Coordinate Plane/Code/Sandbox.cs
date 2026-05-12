using Godot;
using System;

public partial class CartesianPlane
{
    public void Sandbox()
    {
        Circle(new Vector2(0,0), 5);
        LineSegment(new Vector2(8,6), new Vector2(6,7), Colors.Crimson);
        StraightLine(new Vector2(0, 5), new Vector2(5, 0), Colors.White);
        StraightLine(Origin, 1, Colors.White);
        Ray(Origin, new Vector2(4, 2), Colors.Pink);
    }
}
