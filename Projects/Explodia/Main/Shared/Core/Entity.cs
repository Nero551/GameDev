using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public class Entity
{
    public static List<Entity> Entities = new();
    /*
    new framework , entities own components , components do logic.
    interfaces/driver are not owned by entity or owner , instead just work directly with the components somehow.
    drivers provide the needed data to complete the required logic by component.
    research ecs and how it works internally since my framework is super similar.

    its clear i need to learn more about C#, specifically on interfaces.
    */
    private Node Owner;
    private List<Component> Components = new();
    private List<Interface> Interfaces = new();

    public Entity(Node owner)
    {
        Entities.Add(this);
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
        if (HasComponent<T>())
        {
            return Components.OfType<T>().FirstOrDefault();
        }
        return default(T);
    }

    public bool HasComponent<T>() where T : Component, new()
    {
        if (Components.OfType<T>().FirstOrDefault() != null)
        {
            return true;
        }
        return false;
    }

    public T AddInterface<T>() where T : Interface, new()
    {
        var driver = new T();
        Interfaces.Add(driver);
        return driver;
    }

    public bool HasInterface<T>() where T : Interface, new()
    {
        if (Interfaces.OfType<T>().FirstOrDefault() != null)
        {
            return true;
        }
        return false;
    }

    public T GetInterface<T>() where T : Interface, new()
    {
        if (HasInterface<T>())
        {
            return Interfaces.OfType<T>().FirstOrDefault();
        }
        return default(T);
    }
}
