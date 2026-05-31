using Godot;
using System;

public abstract class Component
{
    // Back-reference used to access sibling components and owner interfaces.
    public ComponentHost ComponentHost;
    
    public void Init(ComponentHost componentHost)
    {
        ComponentHost = componentHost;
        OnInit();
    }

    // Override this for custom per Component setup.
    protected virtual void OnInit() { }
}
