using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class Grid
{
    public void LinearEquation(float a, float b, float c)
    {
        List<Point> Points = new();
        for (float X = -100; X <= 100; X++)
        {
            float Y = (-a * X -c) / b;
            Points.Add(CreatePoint(new Vector3(X, Y, 0).ToString(), new Vector3(X, Y, 0)));
        }
        Point A = Points[0];
        Point B = Points[Points.Count - 1];
        CreateLine((A.Position + B.Position).ToString(), A.Position, B.Position);
    }

}
