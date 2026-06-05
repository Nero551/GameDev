using System;
using Godot;

public  interface ITransform3D : Interface
{
    Vector3 Rotation { get; set; }
    Vector3 GlobalPosition { get; set; }
    Godot.Basis Basis {get; set;}
}

