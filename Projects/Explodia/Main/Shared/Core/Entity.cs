using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public class Entity
{
    private Node Owner;
    private List<Component> Components = new();

    public Entity(Node owner)
    {
        Owner = owner;
    }

    public T AddComponent<T>() where T : Component, new()
    {
        var comp = new T();
        comp.Init(Owner, this);
        Components.Add(comp);
        return comp;
    }
    public T GetComponent<T>() where T : Component, new()
    {
        return Components.OfType<T>().FirstOrDefault();
    }
}
