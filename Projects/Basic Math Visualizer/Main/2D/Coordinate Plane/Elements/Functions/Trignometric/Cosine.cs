using Godot;
using System;
using System.Collections.Generic;

public partial class Cosine : Trignometric
{
    public static Cosine Create(string name = default, Color color = default, Node parent = default)
    {
        PackedScene scene = SceneLoader.Load("Cosine");
        Cosine cosineWave = scene.Instantiate<Cosine>();
        cosineWave.Name = name == default ? "Cosine Wave" : name;
        parent = parent == default ? CartesianPlane.Plane.GetNodeOrNull<Node2D>("Content/Functions") : parent;

        for (float i = -20; i < 20; i += cosineWave.IterationInterval / cosineWave.Amplitude)
        {
            MathVector2 pointLocation = new MathVector2(i, cosineWave.Amplitude * Mathf.Cos(cosineWave.Period * i));
            Point point = Point.Create(pointLocation, i.ToString(), color, cosineWave);
            cosineWave.Points.Add(i, point);
        }

        parent.AddChild(cosineWave);
        return cosineWave;
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
            pair.Value.Y = Amplitude * Mathf.Cos(Period * pair.Key);
        }
        Recalculating = false;
    }
}
