using System;
using System.Collections.Generic;
using Godot;

namespace Processors { }

/// <summary>
/// Base class for all simulation processors in the Depths framework.
/// 
/// A Processor is a system that operates globally or over all entities that satisfy
/// a specific block requirement set. It defines lifecycle hooks for:
/// - initialization (Start)
/// - frame processing (Process)
/// - physics processing (PhysicsProcess)
/// </summary>
public abstract class Processor
{
    /// <summary>
    /// Creates and registers a new processor instance in the runtime.
    /// </summary>
    /// <typeparam name="T">Type of processor to create.</typeparam>
    /// <returns>The created processor instance.</returns>
    public static Processor Add<T>() where T : Processor, new()
    {
        T processor = new();
        Game.Runtime.Processors.Add(processor);
        return processor;
    }

    /// <summary>
    /// Determines whether an entity should be processed by this processor.
    /// Override this to define required block conditions.
    /// </summary>
    /// <param name="entity">Entity being evaluated.</param>
    /// <returns>True if the entity should be processed.</returns>
    public virtual bool HasRequiredBlocks(Entity entity)
    {
        return true;
    }

    /// <summary>
    /// Called once when the processor starts.
    /// </summary>
    /// 
    public virtual void Start()
    {
        for (int i = 0; i < Game.Runtime.Entities.Count; i++)
        {
            if (HasRequiredBlocks(Game.Runtime.Entities[i]))
            {
                StartEntities(Game.Runtime.Entities[i]);
            }
        }
    }

    /// <summary>
    /// Called for each valid entity during processor initialization.
    /// </summary>
    /// <param name="entity">Target entity.</param>
    /// 
    public virtual void StartEntities(Entity entity) { }

    /// <summary>
    /// Called every frame for each valid entity.
    /// </summary>
    /// <param name="entity">Target entity.</param>
    /// <param name="delta">Frame delta time.</param>
    /// 
    public virtual void ProcessEntities(Entity entity, double delta) { }

    /// <summary>
    /// Called every physics frame for each valid entity.
    /// </summary>
    /// <param name="entity">Target entity.</param>
    /// <param name="delta">Physics delta time.</param>
    /// 
    public virtual void PhysicsProcessEntities(Entity entity, double delta) { }

    /// <summary>
    /// Executes per-frame processing in the runtime.
    /// </summary>
    /// <param name="delta">Frame delta time.</param>
    /// 
    public virtual void Process(double delta)
    {
        for (int i = 0; i < Game.Runtime.Entities.Count; i++)
        {
            if (HasRequiredBlocks(Game.Runtime.Entities[i]))
            {
                ProcessEntities(Game.Runtime.Entities[i], delta);
            }
        }
    }

    /// <summary>
    /// Executes physics-step processing in the runtime.
    /// </summary>
    /// <param name="delta">Physics delta time.</param>
    /// 
    public virtual void PhysicsProcess(double delta)
    {
        for (int i = 0; i < Game.Runtime.Entities.Count; i++)
        {
            if (HasRequiredBlocks(Game.Runtime.Entities[i]))
            {
                PhysicsProcessEntities(Game.Runtime.Entities[i], delta);
            }
        }
    }
}