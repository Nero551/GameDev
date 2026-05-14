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
        */
        StraightLine AB = StraightLine.Create("AB",Colors.Red);
        AB.A = Origin;
        AB.B = Vector2(5,5);
        // Circle(Vector2(0, 0), 5);
        // LineSegment(Vector2(-6, 5), Vector2(-8, 3), Colors.Crimson);
        // StraightLine strL = StraightLine(Origin, Vector2(5, 5), Colors.White);
        // StraightLine strL2 = StraightLine(Origin, -1 / strL.Slope, Colors.Red);
        // StraightLine(Origin, 1, Colors.White);
        // Ray(Origin, Vector2(-3, 2), Colors.Pink);
    }
}
