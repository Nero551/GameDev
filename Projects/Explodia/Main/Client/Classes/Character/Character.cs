using Godot;
using System;
using System.Linq;

public partial class Character : CharacterBody3D
{
	// Called when the node enters the scene tree for the first time.
	[Export] public float Speed;
	[Export] public float JumpPower;
	public override void _Ready()
	{
		
	}

	// Called every frame. 'delta' is the elapsed time since the previous fram1e.
	public override void _Process(double delta)
	{
	}
}
