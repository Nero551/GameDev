using System;
using System.Collections.Generic;
using Godot;

/// <summary>
/// Core runtime manager for the Depths framework.
/// </summary>
/// <remarks>
/// Handles entity registration, processor execution, and global update loops.
/// Runs both server and client-side simulation systems depending on configuration.
/// </remarks>
/// 
public abstract class Runtime
{
    public int NextEntityId = 0;
    public List<Processor> Processors = [];

    public Dictionary<int, Entity> Entities = [];

    protected virtual void AddProcessors()
    {
        Processor.Add<Processors.ReplicationProcessor>();
    }

    protected virtual void StartServices()
    {
        NetworkService.Start();
    }

    protected virtual void ProcessServices(double delta)
    {
        TimerService.Process(delta);
    }

    public virtual void Start()
    {
        StartServices();
        AddProcessors();

        for (int i = 0; i < Processors.Count; i++)
        {
            Processors[i].Start();
        }
    }

    public virtual void Process(double delta)
    {
        ProcessServices(delta);
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