using Godot;
using System;

public interface ICombatable : Interface
{
    Item ActiveHand { get; }
    
}
