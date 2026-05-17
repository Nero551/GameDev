using Godot;
using System;
using System.Collections.Generic;

public abstract partial class Element<TMode> : Node2D
{
    [Export] public string ElementName;
    public TMode CalculationMode; 
    public bool Recalculating;

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

}
