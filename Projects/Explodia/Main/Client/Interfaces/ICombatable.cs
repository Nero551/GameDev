using Godot;
using System;

public interface ICombatable : Interface
{
    Node3D Rig { get; }
    EItem ActiveHand { get; }
    
}
