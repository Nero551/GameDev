using System;
using System.Collections.Generic;
using Godot;

public abstract class Processor
{
    public static Processor Add<T>() where T : Processor, new()
    {

        T processor = new();
        Game.Runtime.Processors.Add(processor);
        return processor;
    }

    public virtual bool HasRequiredBlocks(Entity entity)
    {
        return true;
    }

    public virtual void Start(Entity entity)
    {

    }

    public virtual void Process(Entity entity, double delta)
    {

    }

    public virtual void PhysicsProcess(Entity entity, double delta)
    {

    }
}
