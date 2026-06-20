using Godot;
using System;


namespace Blocks;

public class MovementBlock : Block
{
	public Vector2 MoveDirection;
	public float Speed = 5;
	public Vector3 Velocity;
}
