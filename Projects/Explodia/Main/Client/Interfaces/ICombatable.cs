using Godot;
using System;

public interface ICombatable : Interface
{
    Node3D Rig { get; }
    Item ActiveHand { get; }
    
}
