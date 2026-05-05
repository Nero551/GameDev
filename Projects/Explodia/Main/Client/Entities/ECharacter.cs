using Godot;
using System;

public partial class ECharacter : CharacterBody3D, IStatable, IMainStatable, ICombatable, IMovable, IMainAnimatible
{
	[Export] public Node3D Rig { get; set; }
	[Export] public Vector2 MoveDirection = Vector2.Zero;

	[Export] public float Speed { get; set; }
	[Export] public float JumpPower { get; set; }

	[Export] public float MaxHealth = 100;
	[Export] public float CurrentHealth { get; set; } = 100;

	[Export] public EItem MainHand;
	[Export] public EItem Offhand;
	[Export] public EItem ActiveHand { get; set; }

	public CAnimations Canimations;
	public CStates Cstates;
	public CMainAnimations CmainAnimations;
	public CMainStates CmainStates;
	public CActionVerifier CactionVerifier;
	public CCombat Ccombat;
	public CMovement Cmovement;

	public Entity Entity;

	public override void _Ready()
	{
		Rig = GetNode<Node3D>("__Animation Dummy_Armature");
		Entity = new Entity(this);


		Cmovement = Entity.AddComponent<CMovement>();
		Cstates = Entity.AddComponent<CStates>();
		CmainStates = Entity.AddComponent<CMainStates>();
		CactionVerifier = Entity.AddComponent<CActionVerifier>();
		Canimations = Entity.AddComponent<CAnimations>();
		GetNode<EWeapon>("Fist").Init(this);
		CmainAnimations = Entity.AddComponent<CMainAnimations>();
		Ccombat = Entity.AddComponent<CCombat>();

	}

	public override void _Process(double delta)
	{

		Cstates.HandleStates(delta);
		CmainStates.HandleMainStates();
		CmainAnimations.MainAnimations();
	}

	public void OnHitMarker()
	{
		Ccombat.OnHitMarker();
	}

	public void OnAnimFinished(string animName)
	{
		Canimations.OnAnimFinished(animName);
	}
}
