using Godot;
using System;

public interface IStatable : Interface
{
    float Speed { get; set; }
    float JumpPower { get; set; }
    float CurrentHealth { get; set; }
}
