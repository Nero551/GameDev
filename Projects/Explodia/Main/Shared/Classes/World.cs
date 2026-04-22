using Godot;
using System;

public partial class World : Node3D
{
	public static Node3D Hitboxes;
	public override void _Ready()
	{
		Hitboxes = GetNodeOrNull<Node3D>("Hitboxes");
	}
}
