using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public class Entity
{
    public static List<Entity> Entities = new();
    /*
    ?Framework Rework:

    Entity owns drivers and components , components own logic , drivers own data.

    components dont know which object owns them , they just check if entity has the drivers and runs on
    the data given by drivers using HasDriver and GetDriver methods inside entity object

    this "Driver" will store data required by the component. that is the piece am missing.

    What i need:
    1-way to dynamically add Drivers
    2-way for those Drivers to store all kinds of data including class specific like Velocity or IsOnFloor()

    perhaps this delegate thing is wut am missing? i will do more research when i can.
    */
    private Node Owner;
    private List<Component> Components = new();

    public Entity(Node owner)
    {
        Entities.Add(this);
        Owner = owner;
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

    public T GetInterface<T>() where T : class, Interface
    {
        if (Owner is T)
        {
            return Owner as T;
        }
        return default(T);
    }
}
