using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Blocks;
using Godot;

namespace Entities { }

/// <summary>
/// Core runtime unit in Depths ECS-like architecture.
/// Holds Blocks (components) and provides lookup, creation, and replication metadata.
/// </summary>
/// <remarks>
/// Entities are globally registered in Game.Runtime.Entities on creation.
/// Each entity can optionally be connected to a Godot Node for rendering/scene binding.
/// </remarks>
/// 
public class Entity
{
    /// <summary>
    /// Mapping of block ID to block instance.
    /// </summary>
    /// 
    public readonly Dictionary<int, Blocks.Block> Blocks = [];

    /// <summary>
    /// Unique runtime identifier for this entity.
    /// </summary>
    /// 
    public int Id;

    /// <summary>
    /// Optional Godot node linked to this entity (visual/scene representation).
    /// </summary>
    /// 
    public Node ConnectedNode;

    /// <summary>
    /// Creates a new entity instance.
    /// </summary>
    /// 
    public static Entity Create()
    {
        Entity entity = new();
        return entity;
    }

    /// <summary>
    /// Creates a strongly-typed entity instance.
    /// </summary>
    /// 
    public static T Create<T>() where T : Entity, new()
    {
        T entity = new();
        return entity;
    }

    /// <summary>
    /// Initializes a new entity and registers it in the runtime.
    /// </summary>
    /// 
    protected Entity()
    {
        Initialize();
        Id = Game.Runtime.NextEntityId++;
        Game.Runtime.Entities[Id] = this;
    }

    /// <summary>
    /// Override point for entity setup logic.
    /// Called during construction before registration.
    /// </summary>
    /// 
    protected virtual void Initialize() { }

    /// <summary>
    /// Removes this entity from the runtime registry.
    /// </summary>
    /// 
    public void Destroy()
    {
        Game.Runtime.Entities.Remove(Id);
    }

    /// <summary>
    /// Attaches a Godot node to this entity.
    /// </summary>
    /// <typeparam name="T">Node type.</typeparam>
    /// <param name="node">Node instance to attach.</param>
    /// <returns>The connected node.</returns>
    /// 
    public Node ConnectTo<T>(T node) where T : Node
    {
        ConnectedNode = node;
        return ConnectedNode;
    }

    /// <summary>
    /// Gets the connected node as a specific type.
    /// </summary>
    /// <typeparam name="T">Expected node type.</typeparam>
    /// <returns>Connected node cast to type T.</returns>
    /// <exception cref="Exception">Thrown if no node is connected.</exception>
    /// 
    public T GetNode<T>() where T : Node
    {
        if (ConnectedNode == null)
        {
            throw new Exception($"Connected Node Of Entity[{Id}] Doesn't Exist");
        }
        return ConnectedNode as T;
    }

    /// <summary>
    /// Adds a block to the entity if it does not already exist.
    /// </summary>
    /// <typeparam name="T">Block type.</typeparam>
    /// <returns>The existing or newly created block.</returns>
    /// 
    public T AddBlock<T>() where T : Blocks.Block, new()
    {
        foreach (int key in Blocks.Keys)
        {
            if (Blocks.TryGetValue(key, out Blocks.Block existingBlock) && existingBlock is T)
            {
                return existingBlock as T;
            }
        }

        int blockId = Blocks.Count;
        var block = new T { EntityId = Id };
        Blocks.Add(blockId, block);

        MarkReplicatedFields(block);
        return block;
    }

    /// <summary>
    /// Gets a block of type T from this entity.
    /// </summary>
    /// <typeparam name="T">Block type.</typeparam>
    /// <returns>The block instance or default if not found.</returns>
    /// 
    public T GetBlock<T>() where T : Blocks.Block
    {
        if (HasBlock<T>())
        {
            foreach (int key in Blocks.Keys)
            {
                if (Blocks.TryGetValue(key, out Blocks.Block block) && block is T)
                {
                    return block as T;
                }
            }
        }
        return default;
    }

    /// <summary>
    /// Gets a block by its numeric ID.
    /// </summary>
    /// <param name="blockId">Block identifier.</param>
    /// <returns>The block instance.</returns>
    /// <exception cref="Exception">Thrown if block does not exist.</exception>
    /// 
    public Blocks.Block GetBlock(int blockId)
    {
        return Blocks.ContainsKey(blockId)
            ? Blocks[blockId]
            : throw new Exception($"Entity: {Id} Doesn't Have Block: {blockId}");
    }

    /// <summary>
    /// Scans a block for fields marked with [Replicated] and registers them.
    /// </summary>
    /// <param name="block">Block to scan.</param>
    /// 
    private void MarkReplicatedFields(Blocks.Block block)
    {
        int fieldId = 0;

        foreach (FieldInfo field in block.GetType()
                    .GetFields(BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic))
        {
            if (Attribute.IsDefined(field, typeof(Replicated)))
            {
                block.ReplicatedFields.Add(
                    fieldId,
                    new ReplicatedField(field, field.GetCustomAttribute<Replicated>()));

                fieldId++;
            }
        }
    }

    /// <summary>
    /// Checks if the entity contains a block of type T.
    /// </summary>
    /// 
    public bool HasBlock<T>() where T : Blocks.Block
    {
        foreach (int key in Blocks.Keys)
        {
            if (Blocks.TryGetValue(key, out Blocks.Block block) && block is T)
            {
                return true;
            }
        }
        return false;
    }

    /// <summary>
    /// Checks if the entity contains two block types.
    /// </summary>
    /// 
    public bool HasBlock<T1, T2>()
        where T1 : Blocks.Block
        where T2 : Blocks.Block
    {
        return HasBlock<T1>() && HasBlock<T2>();
    }

    /// <summary>
    /// Checks if the entity contains three block types.
    /// </summary>
    /// 
    public bool HasBlock<T1, T2, T3>()
        where T1 : Blocks.Block
        where T2 : Blocks.Block
        where T3 : Blocks.Block
    {
        return HasBlock<T1>() && HasBlock<T2>() && HasBlock<T3>();
    }
}