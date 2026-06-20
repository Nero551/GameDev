using System;
using System.Collections.Generic;
using System.Linq;
using Godot;


namespace Entities { }
public class Entity
{
    public static int NextId = 0;

    private readonly List<Blocks.Block> Blocks = [];
    public int Id;
    public Node ConnectedNode;

    public static Entity Create()
    {
        Entity entity = new();
        return entity;
    }

    public static Entity Create<T>() where T : Entity, new()
    {
        T entity = new();
        return entity;
    }

    protected Entity()
    {
        Initialize();
        Game.Runtime.Entities.Add(this);
        Id = NextId++;
    }

    protected virtual void Initialize() { }

    public void Destroy()
    {
        Game.Runtime.Entities.Remove(this);
    }

    public void ConnectTo<T>(T node) where T : Node
    {
        ConnectedNode = node;
    }

    public T GetNode<T>() where T : Node
    {
        return ConnectedNode as T;
    }

    public T AddBlock<T>() where T : Blocks.Block, new()
    {
        //Check if it already exists.
        for (int i = 0; i < Blocks.Count; i++)
        {
            if (Blocks[i] is T existingBlock)
            {
                return existingBlock;
            }
        }

        var block = new T { Entity = this };
        Blocks.Add(block);
        return block;
    }
    public T GetBlock<T>() where T : Blocks.Block
    {
        if (HasBlock<T>())
        {
            for (int i = 0; i < Blocks.Count; i++)
            {
                if (Blocks[i] is T block)
                    return block;
            }
            ;
        }
        return null;
    }

    public bool HasBlock<T>() where T : Blocks.Block
    {
        for (int i = 0; i < Blocks.Count; i++)
        {
            if (Blocks[i] is T)
                return true;
        }
        return false;
    }
    public bool HasBlock<T1, T2>() where T1 : Blocks.Block where T2 : Blocks.Block
    {
        return HasBlock<T1>() && HasBlock<T2>();
    }

    public bool HasBlock<T1, T2, T3>() where T1 : Blocks.Block where T2 : Blocks.Block where T3 : Blocks.Block
    {
        return HasBlock<T1>() && HasBlock<T2>() && HasBlock<T3>();
    }

    // public T GetInterface<T>() where T : class, Interface
    // {
    //     // Interfaces expose built-in owner data, such as Velocity or IsOnFloor().
    //     if (Owner is T)
    //     {
    //         return Owner as T;
    //     }
    //     return null;
    // }
}
