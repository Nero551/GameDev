using System;
using Godot;

public partial class Item : Node3D
{
    [Export] public Godot.Collections.Dictionary ItemData;
    [Export] public AnimationLibrary AnimationLibrary;
    [Export] public Character Master;

    public virtual void InitClass()
    {

    }
    public void Init(Character master)
    {
        Master = master;
        Master.ActiveHand = this;
        InitClass();
    }
}
