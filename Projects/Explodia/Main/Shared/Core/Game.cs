using Godot;
using System;
using System.Diagnostics;

public partial class Game : Node
{
	public static Node Hitboxes;
	public static Node Players;
	public static Node Characters;

	public override void _EnterTree()
	{
		Players = GetNodeOrNull<Node>("Players");
		Characters = GetNodeOrNull<Node>("Characters");
		Hitboxes = GetNodeOrNull<Node>("Hitboxes");
	}
}
