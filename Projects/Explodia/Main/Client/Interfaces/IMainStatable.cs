using Godot;
using System;

public interface IMainStatable
{
    bool IsOnFloor();
    Vector3 Velocity { get; set; }
}
