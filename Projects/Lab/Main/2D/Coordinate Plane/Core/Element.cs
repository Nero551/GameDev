using Godot;
using System;
using System.Collections.Generic;

public abstract partial class Element<TMode> : Node2D
{

    [Export] public bool Delete { get; set { field = !value; Destroy(); } }
    [Export] public string ElementName;
    protected TMode CalculationMode;
    protected bool Recalculating;
    // protected float LerpWeight = 0.2f;

    protected virtual void Recalculate() { }
    protected void SetProperty<T>(ref T propertyRef, T value, TMode mode)
    {
        if (!EqualityComparer<T>.Default.Equals(propertyRef, value))
        {
            propertyRef = value;
            if (Recalculating == false)
            {
                CalculationMode = mode;
                Recalculating = true;
                Recalculate();
            }
        }
    }

    public void Destroy()
    {
        QueueFree();
    }

}
