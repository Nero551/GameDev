using Godot;
using System;

public interface IAnimatible
{
    int CurrentAnimPriority { get; set;}
    string CurrentAnim { get; set; }
}
