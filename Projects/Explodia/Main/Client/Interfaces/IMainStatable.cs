using Godot;
using System;

public interface IMainStatable : Interface
{
    bool IsOnFloor();
    Vector3 Velocity { get; set; }
}
