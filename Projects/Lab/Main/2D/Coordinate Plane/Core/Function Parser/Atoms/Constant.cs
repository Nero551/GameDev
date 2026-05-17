using Godot;
using System;

public partial class Constant : Atom
{
    public float Value;

    public Constant(float value)
    {
        Value = value;
    }

    protected float Evaluate()
    {
        return Value;
    }
}
