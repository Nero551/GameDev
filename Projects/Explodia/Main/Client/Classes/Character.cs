using Godot;
using System;

public partial class Character : CharacterBody3D, IStatable, IMainStatable, ICombatable, IMovable, IMainAnimatible
{
	[Export] public Node3D Rig { get; set; }
	[Export] public Vector2 MoveDirection = Vector2.Zero;

	[Export] public float Speed { get; set; }
	[Export] public float JumpPower { get; set; }

	[Export] public float MaxHealth = 100;
	[Export] public float CurrentHealth { get; set; } = 100;

	[Export] public Item MainHand;
	[Export] public Item Offhand;
	[Export] public Item ActiveHand { get; set; }

	public CompAnimations compAnimations;
	public CompStates compStates;
	public CompMainAnimations compMainAnimations;
	public CompMainStates compMainStates;
	public CompActionVerifier compActionVerifier;
	public CompCombat compCombat;
	public CompMovement compMovement;

	public Entity entity;

	public override void _Ready()
	{
		Rig = GetNode<Node3D>("__Animation Dummy_Armature");
		entity = new Entity(this);


		compMovement = entity.AddComponent<CompMovement>();
		compStates = entity.AddComponent<CompStates>();
		compMainStates = entity.AddComponent<CompMainStates>();
		compActionVerifier = entity.AddComponent<CompActionVerifier>();
		compAnimations = entity.AddComponent<CompAnimations>();
		GetNode<Weapon>("Fist").Init(this);
		compMainAnimations = entity.AddComponent<CompMainAnimations>();
		compCombat = entity.AddComponent<CompCombat>();

	}

	public override void _Process(double delta)
	{
		compStates.HandleStates(delta);
		compMainStates.HandleMainStates();
		compMainAnimations.MainAnimations();
	}

	public void OnHitMarker()
	{
		compCombat.OnHitMarker();
	}
}
