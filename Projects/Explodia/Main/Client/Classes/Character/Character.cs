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
	[Export] public MainStates MainState;

	[Export] public float Speed;
	[Export] public float JumpPower;
	[Export] public float MaxHealth = 100;
	[Export] public float CurrentHealth = 100;

	[Export] public Item MainHand;
	[Export] public Item Offhand;
	[Export] public Item ActiveHand;

	[Export] public int BlockCounter;
	[Export] public int SwingNumber = 0;
	[Export] public double LastSwingTime = 0;
	[Export] public double LastComboTime = 0;

	[Export] public int CurrentAnimPriority = 3;
	[Export] public string CurrentAnim = "";

	public override void _Process(double delta)
	{
		UpdateStatesDuration(delta);
		HandleStates(delta);
		UpdateMainStates();
		MainAnimations();
	}
}
