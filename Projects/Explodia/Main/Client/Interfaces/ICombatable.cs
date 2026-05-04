using Godot;
using System;

public interface ICombatable
{
    Node3D Rig { get; }
    EItem ActiveHand { get; }
}
