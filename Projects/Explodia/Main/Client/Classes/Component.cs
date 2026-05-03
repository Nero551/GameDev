using Godot;
using System;

public abstract class Component
{
    public Node Owner;
    public Entity Entity;

    public void Init(Node owner, Entity entity)
    {
        Owner = owner;
        Entity = entity;
        OnInit();
    }

    protected virtual void OnInit() { }
}
