using System;
using System.Collections.Generic;
using System.Linq;
using Godot;


namespace Entities { }
public class Entity
{
    public static int NextId = 0;
    // The Godot object that owns this host and exposes engine data through interfaces.

    // Blocks hold gameplay logic and the data created by that logic.
    public int Id;
    private readonly List<Blocks.Block> Blocks = [];

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

    Entity()
    {
        Game.Runtime.Entities.Add(this);
        Id = NextId++;
    }
    public void Destory()
    {
        Game.Runtime.Entities.Remove(this);
    }

    public T AddBlock<T>() where T : Blocks.Block, new()
    {
        // Blocks are created by the host so they can be initialized with this owner.

        //Check if it already exists.
        for (int i = 0; i < Blocks.Count; i++)
        {
            if (Blocks[i] is T typed)
            {
                return typed;
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
            return Blocks.OfType<T>().FirstOrDefault();
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
