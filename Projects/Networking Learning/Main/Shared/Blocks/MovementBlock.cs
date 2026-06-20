using System;
using Godot;


namespace Blocks;

public class MovementBlock : Block
{
    public Vector2 MoveDirection;
    public float Speed = 5;
    [Replicated] public Vector3 Velocity;
}
