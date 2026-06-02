using Godot;
using System;
using System.Collections.Generic;

public partial class Tangent : Trignometric
{
    public static Tangent Create(string name = default, Color color = default, Node parent = default)
    {
        PackedScene scene = SceneLoader.Load("Tangent");
        Tangent tangentWave = scene.Instantiate<Tangent>();
        tangentWave.Name = name == default ? "Tangent Wave" : name;
        parent = parent == default ? CartesianPlane.Plane.GetNodeOrNull<Node2D>("Content/Functions") : parent;

        for (float i = -20; i < 20; i += tangentWave.IterationInterval / tangentWave.Amplitude)
        {
            MathVector2 pointLocation = new MathVector2(i, tangentWave.Amplitude * Mathf.Tan(tangentWave.Period * i));
            Point point = Point.Create(pointLocation, i.ToString(), color, tangentWave);
            tangentWave.Points.Add(i, point);
        }

        parent.AddChild(tangentWave);
        return tangentWave;
    }

    protected override void Recalculate()
    {
        switch (CalculationMode)
        {
            case CalculationModes.Amplitude:
                break;
            case CalculationModes.Period:
                break;
            default:
                break;
        }
        foreach (KeyValuePair<float, Point> pair in Points)
        {
            pair.Value.X = pair.Key;
            pair.Value.Y = Amplitude * Mathf.Tan(Period * pair.Key);
        }
        Recalculating = false;
    }
}
