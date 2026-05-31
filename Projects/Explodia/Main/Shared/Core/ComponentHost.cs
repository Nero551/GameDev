using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

public class ComponentHost
{
    // The Godot object that owns this host and exposes engine data through interfaces.
    public Node Owner;
    // Components hold gameplay logic and the data created by that logic.
    private List<Component> Components = new();

    public static ComponentHost Create(Node owner)
    {
        return new ComponentHost(owner);
    }

    ComponentHost(Node owner)
    {
        Owner = owner;
    }

    public T AddComponent<T>() where T : Component, new()
    {
        // Components are created by the host so they can be initialized with this owner.
        var comp = new T();
        comp.Init(this);
        Components.Add(comp);
        return comp;
    }
    public T GetComponent<T>() where T : Component
    {
        if (HasComponent<T>())
        {
            return Components.OfType<T>().FirstOrDefault();
        }
        return null;
    }

    public bool HasComponent<T>() where T : Component
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
        return null;
    }
}
