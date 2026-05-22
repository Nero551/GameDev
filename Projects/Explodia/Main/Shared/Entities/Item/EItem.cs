using System;
using Godot;

public partial class EItem : Node3D
{
    [Export] public Godot.Collections.Dictionary ItemData;
    [Export] public AnimationLibrary AnimationLibrary;
    [Export] public ECharacter Master;

    public virtual void InitClass()
    {

    }
    public void Init(ECharacter master)
    {
        Master = master;
        Master.ActiveHand = this;
        InitClass();
    }
}
