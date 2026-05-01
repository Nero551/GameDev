using Godot;
using System;
using System.Diagnostics;

public partial class World : Node3D
{
	public static Node Hitboxes;
	public static Node Players;
	public static Node Characters;
	public static Camera3D DebugCam;

	public override void _EnterTree()
	{
		Players = GetNodeOrNull<Node>("Players");
		Characters = GetNodeOrNull<Node>("Characters");
		Hitboxes = GetNodeOrNull<Node>("Hitboxes");
		DebugCam = GetNodeOrNull<Camera3D>("Freecam3D");
	}
}
