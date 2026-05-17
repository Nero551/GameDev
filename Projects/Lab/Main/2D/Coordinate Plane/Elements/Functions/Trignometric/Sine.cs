using Godot;
using System;
using System.Collections.Generic;

public partial class Sine : Trignometric
{
    public static Sine Create(string name = default, Color color = default, Node parent = default)
    {
        PackedScene scene = SceneLoader.Load("Sine");
        Sine sineWave = scene.Instantiate<Sine>();
        sineWave.Name = name == default? "Sine Wave": name;
        parent = parent == default ? CartesianPlane.Plane.GetNodeOrNull<Node2D>("Content/Functions") : parent;

        for (float i = -20; i < 20; i += sineWave.IterationInterval / sineWave.Amplitude)
        {
            MathVector2 pointLocation = new MathVector2(i, sineWave.Amplitude * Mathf.Sin(sineWave.Period * i));
            Point point = Point.Create(pointLocation, i.ToString(), color, sineWave);
            sineWave.Points.Add(i, point);
        }

        parent.AddChild(sineWave);
        return sineWave;
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
            pair.Value.Y = Amplitude * Mathf.Sin(Period * pair.Key);
        }
        Recalculating = false;
    }
}
