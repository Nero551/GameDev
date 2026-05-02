using Godot;
using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;

public partial class Grid
{
    public void QuadraticEquation(float a, float b, float c)
    {
        List<Point> Points = new();
        for (float x = -5; x <= 5; x += 0.1f)
        {
            float y = (a * Mathf.Pow(x, 2) + b * x + c);

            Points.Add(CreatePoint(new Vector3(x, y, 0).ToString(), new Vector3(x, y, 0)));
        }

        for (int i = 0; i <= Points.Count - 2; i++)
        {
            CreateLine(Points[i].Position + Points[i + 1].Position.ToString(), Points[i].Position, Points[i + 1].Position);
        }
        foreach (Point point in Points)
        {
        }
    }
}
