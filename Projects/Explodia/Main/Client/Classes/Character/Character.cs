using Godot;
using System;

public partial class Character : CharacterBody3D, IAnimatible
{
	private AnimationsComponent animationsComponent = new AnimationsComponent();

	public override void _Ready()
	{
		
		Rig = GetNode<Node3D>("__Animation Dummy_Armature");
		animationsComponent.Init(this);
		InitStates();
		GetNode<Weapon>("Fist").Init(this);
	}
	[Export] public MainStates MainState;

	[Export] public Node3D Rig;
	[Export] public Vector2 MoveDirection = Vector2.Zero;

	[Export] public float Speed;
	[Export] public float JumpPower;

	[Export] public float MaxHealth = 100;
	[Export] public float CurrentHealth = 100;

	[Export] public Item MainHand;
	[Export] public Item Offhand;
	[Export] public Item ActiveHand;

	[Export] public int SwingNumber = 0;
	[Export] public double LastSwingTime = 0;
	[Export] public double LastComboTime = 0;

	[Export] public int CurrentAnimPriority = 3;
	[Export] public string CurrentAnim = "";

	public override void _Process(double delta)
	{
		HandleStates(delta);
		HandleMainStates();
		MainAnimations();
	}
}
