using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public class Entity
{
    public static int EntityLimit = 999;
    public static int slot = 0;
    public static Entity[] Entities = new Entity[EntityLimit];

    /*
    ?Framework Rework:
    Entities Contain Components
    Components Contain Logic and Relevant Data THEY create (Health, AnimPriority,etc).
    Built-in Data Required by Components such as Velocity is acquired through interfaces.

    TODO-decrease amount of interfaces, limit them to only built-in engine data(E.X IVelocity)
    */
    public Node Owner;
    private int id;
    private List<Component> Components = new();

    public static Entity Create(Node owner)
    {
        if (slot == EntityLimit)
        {
            GD.PushWarning("Exceeded Entity Limit!!");
            return null;
        }
        return new Entity(owner);
    }

    public Entity(Node owner)
    {
        id = slot;
        Entities[slot] = this;
        slot++;
        Owner = owner;
    }

    ~Entity()
    {
        Entities[id] = null;
    }

    public T AddComponent<T>() where T : Component, new()
    {
        var comp = new T();
        comp.Init(this);
        Components.Add(comp);
        return comp;
    }
    public T GetComponent<T>() where T : Component, new()
    {
        if (HasComponent<T>())
        {
            return Components.OfType<T>().FirstOrDefault();
        }
        return null;
    }

    public bool HasComponent<T>() where T : Component, new()
    {
        if (Components.OfType<T>().FirstOrDefault() != null)
        {
            return true;
        }
        return false;
    }

    public T GetInterface<T>() where T : class, Interface
    {
        if (Owner is T)
        {
            return Owner as T;
        }
        return default(T);
    }
}
