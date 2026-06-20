using System;
using System.Collections.Generic;
using Godot;

namespace Processors { }
public abstract class Processor
{
    public static Processor Add<T>() where T : Processor, new()
    {

        T processor = new();
        Game.Runtime.Processors.Add(processor);
        return processor;
    }

    public virtual void Init() { }

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
