using Godot;
using System;

public abstract class Component
{
    public Node Owner;

    public void Init(Node owner)
    {
        Owner = owner;
        OnInit();
    }

    protected virtual void OnInit(){}
}
