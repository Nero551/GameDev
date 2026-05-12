using Godot;
using System;

public partial class CartesianPlane
{
    public void Sandbox()
    {
        // Circle(new Vector2(0,0), 5);
        // LineSegment(Origin, new Vector2(3,4), Colors.Crimson);
        // LineSegment(Origin, new Vector2(3, 0), Colors.DeepSkyBlue);
        // LineSegment(new Vector2(3, 0), new Vector2(3, 4), Colors.DarkGreen);
        StraightLine(new Vector2(0, 5), new Vector2(5, 0), Colors.White);
        Ray(Origin, new Vector2(5, 5), Colors.Pink);
        Ray(Origin, new Vector2(-5, -5), Colors.Pink);
        Ray(Origin, new Vector2(-5, 5), Colors.Pink);
        Ray(Origin, new Vector2(5, -5), Colors.Pink);
        Ray(new Vector2(-5, -5), new Vector2(-7, 5), Colors.Pink);

        // LineSegment(new Vector2(5,5), new Vector2(10,10),Colors.Beige);
        // StraightLine(Origin, new Vector2(30, -25), Colors.Blue);
        // CreateLine(new Vector2(30, -25), new Vector2(30, 5), Colors.Red);
        // CreateLine(new Vector2(0, 4), new Vector2(3, 0));
    }
}
