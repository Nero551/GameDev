using Godot;
using Godot.NativeInterop;
using System;

public partial class CartesianPlane
{
    public void Sandbox()
    {
        /* 
        * i think a scalable and better method than this is to make them classes.
        * each class will be like "Straight Line" it containts properties like Slope, Angle , etc
        * a process method inside class adjusts the values every 2 seconds or so.
        * will make it easier to use and real-time changes.
        * each will have a create method to create an instance of the class including custom "constructers"

        * i need some sort of way to seperate my game into 2 layers.
        * Math Layer: where all the magic happens.
        * Render Layer which converts math layer to work with godot (flips Y axis and scales to basis).
        * am thinking 2 functions that act as conversion layer , math to render and render to math.

        * am thinking custom Math Vector struct then render layer takes it an adjusts to engine
        * so lets lay out the plan
        * 1-make custom Math Vector struct
        * 2- make converter between render to math and vice versa
        * 3- seperate the layers to avoid confusion
        */
        MathVector2 A = new MathVector2(3, 1);
        MathVector2 B = new MathVector2(5, 5);
        // Point.Create(B, "B");
        LineSegment line = LineSegment.Create("AB", Colors.Blue);
        line.AX = 0;
        line.AY = 0;
        line.BY = 5;
        line.BX = 5;
        line.AngleRad  = 1;
        // GD.Print((A + B).X);

        // StraightLine AB = StraightLine.Create("AB",Colors.Red);
        // AB.A = Origin;
        // AB.B = Vector2(5,5);
        // Circle(Vector2(0, 0), 5);
        // LineSegment(Vector2(-6, 5), Vector2(-8, 3), Colors.Crimson);
        // StraightLine strL = StraightLine(Origin, Vector2(5, 5), Colors.White);
        // StraightLine strL2 = StraightLine(Origin, -1 / strL.Slope, Colors.Red);
        // StraightLine(Origin, 1, Colors.White);
        // Ray(Origin, Vector2(-3, 2), Colors.Pink);
    }
}
