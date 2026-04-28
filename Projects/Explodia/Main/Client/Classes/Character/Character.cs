using Godot;
using System;
using System.Security.Cryptography.X509Certificates;

public partial class Character : CharacterBody3D
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		InitAnim();
		InitStates();
		GetNode<Weapon>("Fist").Init(this);
	}

	[Export] public int CurrentAnimPriority = 3;
	[Export] public string CurrentAnim = "";

	public override void _Process(double delta)
	{
		UpdateStatesDuration(delta);
		HandleStates(delta);
		MainAnimations();
	}
}
