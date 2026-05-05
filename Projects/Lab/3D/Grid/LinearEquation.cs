using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class Grid3D
{
    public void LinearEquation(float a, float b, float c)
    {
        List<Point3D> Points = new();
        for (float X = -100; X <= 100; X++)
        {
            float Y = (-a * X -c) / b;
            Points.Add(CreatePoint(new Vector3(X, Y, 0).ToString(), new Vector3(X, Y, 0)));
        }
        Point3D A = Points[0];
        Point3D B = Points[Points.Count - 1];
        CreateLine((A.Position + B.Position).ToString(), A.Position, B.Position);
    }

}
