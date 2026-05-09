using Godot;
using System;

public abstract class Component
{
    // Back-reference used to access sibling components and owner interfaces.
    public Entity Entity;
    
    public void Init(Entity entity)
    {
        Entity = entity;
        OnInit();
    }

    // Override this for setup that needs the Entity reference.
    protected virtual void OnInit() { }
}
