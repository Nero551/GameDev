using System;
using System.Collections.Generic;
using Godot;

public abstract class Runtime
{
    public List<Processor> Processors = [];
    public List<Entity> Entities = [];

    protected virtual void AddProcessors()
    {

    }

    public virtual void Start()
    {
        

        for (int i = 0; i < Processors.Count; i++)
        {
            for (int j = 0; j < Entities.Count; j++)
            {
                if (Processors[i].HasRequiredBlocks(Entities[j]))
                {
                    Processors[i].Start(Entities[j]);
                }
            }
        }
    }

    public virtual void Process(double delta)
    {
        for (int i = 0; i < Processors.Count; i++)
        {
            for (int j = 0; j < Entities.Count; j++)
            {
                if (Processors[i].HasRequiredBlocks(Entities[j]))
                {
                    Processors[i].Process(Entities[j], delta);
                }
            }
        }
    }

    public virtual void PhysicsProcess(double delta)
    {
        for (int i = 0; i < Processors.Count; i++)
        {
            for (int j = 0; j < Entities.Count; j++)
            {
                if (Processors[i].HasRequiredBlocks(Entities[j]))
                {
                    Processors[i].PhysicsProcess(Entities[j], delta);
                }
            }
        }
    }
}
