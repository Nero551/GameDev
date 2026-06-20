using System;
using System.Collections.Generic;
using Godot;

public abstract class Runtime
{
    public int NextEntityId = 0;
    public List<Processor> Processors = [];
    public Dictionary<int, Entity> Entities = [];

    protected virtual void AddProcessors()
    {
        //* Shared Between Server & Client
        Processor.Add<Processors.ReplicationProcessor>();
    }

    public virtual void Start()
    {
        AddProcessors();

        for (int i = 0; i < Processors.Count; i++)
        {
            Processors[i].Start();
        }
    }

    public virtual void Process(double delta)
    {
        for (int i = 0; i < Processors.Count; i++)
        {
            Processors[i].Process(delta);
        }
    }

    public virtual void PhysicsProcess(double delta)
    {
        for (int i = 0; i < Processors.Count; i++)
        {
            Processors[i].PhysicsProcess(delta);
        }
    }
}
