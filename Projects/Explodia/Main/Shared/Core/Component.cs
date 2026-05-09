using Godot;
using System;

public abstract class Component
{
    public Entity Entity;
    
    public void Init(Entity entity)
    {
        Entity = entity;
        OnInit();
    }

    protected virtual void OnInit() { }
}
