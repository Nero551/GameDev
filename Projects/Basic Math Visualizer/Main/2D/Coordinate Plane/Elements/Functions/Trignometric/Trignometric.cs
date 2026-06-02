using Godot;
using System;
using System.Collections.Generic;

public partial class Trignometric : Function<Trignometric.CalculationModes>
{
    public enum CalculationModes
    {
        Amplitude,
        Period
    }

    [Export] public float Amplitude { get; set => SetProperty<float>(ref field, value, CalculationModes.Amplitude); } = 1;
    [Export] public float Period { get; set => SetProperty<float>(ref field, value, CalculationModes.Period); } = 1;
    [Export] public float OriginX;
    [Export] public float OriginY;
    [Export] public float Orientation;
    protected Dictionary<float, Point> Points = new();
    protected float IterationInterval = 0.05f;
    public override void _Process(double delta)
    {
        Position = Converter.VectorMathToRender(new MathVector2(OriginX, OriginY));
        Rotation = Converter.AngleMathToRender(Mathf.DegToRad(Orientation));
    }
}
