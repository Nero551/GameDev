using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Blocks;
using Godot;

namespace Entities { }

/// <summary>
/// Core runtime unit in Depths ECS-like architecture.
/// Holds Blocks and provides lookup, creation, and replication metadata.
/// </summary>
/// <remarks>
/// Entities are globally registered in Game.Runtime.Entities on creation.
/// Each entity can optionally be connected to a Godot Node for rendering/scene binding.
/// </remarks>
/// 
public class Entity
{
    public readonly Dictionary<int, Blocks.Block> Blocks = [];
    public Node ConnectedNode;
    public int Id;

    public static Entity Create()
    {
        Entity entity = new();
        return entity;
    }

    public static T Create<T>() where T : Entity, new()
    {
        T entity = new();
        return entity;
    }

    protected Entity()
    {
        Initialize();
        Id = Game.Runtime.NextEntityId++;
        Game.Runtime.Entities[Id] = this;
    }

    protected virtual void Initialize() { }

    public void Destroy()
    {
        Game.Runtime.Entities.Remove(Id);
    }

    public Node ConnectTo<T>(T node) where T : Node
    {
        ConnectedNode = node;
        return ConnectedNode;
    }

    public T GetNode<T>() where T : Node
    {
        if (ConnectedNode == null)
        {
            throw new Exception($"Connected Node Of Entity[{Id}] Doesn't Exist");
        }
        return ConnectedNode as T;
    }

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

    public Blocks.Block GetBlock(int blockId)
    {
        return Blocks.ContainsKey(blockId) ? Blocks[blockId] : throw new Exception($"Entity: {Id} Doesn't Have Block: {blockId}");
    }

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

    public bool HasBlock<T1, T2>()
        where T1 : Blocks.Block
        where T2 : Blocks.Block
    {
        return HasBlock<T1>() && HasBlock<T2>();
    }

    public bool HasBlock<T1, T2, T3>()
        where T1 : Blocks.Block
        where T2 : Blocks.Block
        where T3 : Blocks.Block
    {
        return HasBlock<T1>() && HasBlock<T2>() && HasBlock<T3>();
    }
}