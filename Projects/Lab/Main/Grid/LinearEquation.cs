using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class Grid
{
    public void LinearEquation(float a, float b, float c)
    {
        //? aX + bY + c = 0
        //? 3X + 5Y + 8 = 0
        List<Point> Points = new();
        for (float i = -15; i <= 15; i++)
        {
            float X = (-c - (i * b)) / a;
            float Y = (-c - (i * a)) / b;
            Points.Add(CreatePoint(new Vector3(X, Y, 0).ToString(), new Vector3(X, Y, 0)));
        }
        Point A = Points[0];
        Point B = Points[Points.Count - 1];
        CreateLine((A.Position + B.Position).ToString(), A.Position, B.Position);
    }

}
