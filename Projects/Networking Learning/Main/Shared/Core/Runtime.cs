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
    /// <summary>
    /// Next available unique entity ID.
    /// </summary>
    /// 
    public int NextEntityId = 0;

    /// <summary>
    /// List of active processors responsible for entity logic.
    /// </summary>
    /// 
    public List<Processor> Processors = [];

    /// <summary>
    /// Global registry of all active entities.
    /// Key = Entity ID.
    /// </summary>
    /// 
    public Dictionary<int, Entity> Entities = [];

    /// <summary>
    /// Registers default processors shared between server and client.
    /// Override to add custom systems.
    /// </summary>
    /// 
    protected virtual void AddProcessors()
    {
        Processor.Add<Processors.ReplicationProcessor>();
    }

    /// <summary>
    /// Initializes runtime and starts all processors.
    /// </summary>
    /// 
    public virtual void Start()
    {
        AddProcessors();

        for (int i = 0; i < Processors.Count; i++)
        {
            Processors[i].Start();
        }
    }

    /// <summary>
    /// Runs the main update loop for all processors.
    /// </summary>
    /// <param name="delta">Time elapsed since last frame.</param>
    /// 
    public virtual void Process(double delta)
    {
        for (int i = 0; i < Processors.Count; i++)
        {
            Processors[i].Process(delta);
        }
    }

    /// <summary>
    /// Runs the physics update loop for all processors.
    /// </summary>
    /// <param name="delta">Physics timestep.</param>
    /// 
    public virtual void PhysicsProcess(double delta)
    {
        for (int i = 0; i < Processors.Count; i++)
        {
            Processors[i].PhysicsProcess(delta);
        }
    }
}