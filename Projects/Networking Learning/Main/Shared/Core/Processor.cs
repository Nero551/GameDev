using System;
using System.Collections.Generic;
using Godot;

public class Processor
{
    public static Processor Add<T>(ref List<Processor> processors) where T : Processor, new()
    {
        T processor = new T();
        processors.Add(processor);
        return processor;
    }

    public virtual void Start()
    {

    }

    public virtual void Process(double delta)
    {

    }

    public virtual void PhysicsProcess(double delta)
    {

    }
}
