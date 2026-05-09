using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public class Entity
{
    // Simple global registry for entities, indexed by creation slot.
    public static int EntityLimit = 999;
    public static int slot = 0;
    public static Entity[] Entities = new Entity[EntityLimit];

    // The Godot object that owns this entity and exposes engine data through interfaces.
    public Node Owner;
    private int id;

    // Components hold gameplay logic and the data created by that logic.
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
        // Store this entity in the global registry before advancing the next free slot.
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
        // Components are created by the entity so they can be initialized with this owner.
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
        // Interfaces expose built-in owner data, such as Velocity or IsOnFloor().
        if (Owner is T)
        {
            return Owner as T;
        }
        return default(T);
    }
}
