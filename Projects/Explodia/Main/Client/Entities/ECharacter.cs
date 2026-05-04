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

	public CAnimations CAnimations;
	public CStates CStates;
	public CMainAnimations CMainAnimations;
	public CMainStates CMainStates;
	public CActionVerifier CActionVerifier;
	public CCombat CCombat;
	public CMovement CMovement;

	public Entity Entity;

	public override void _Ready()
	{
		Rig = GetNode<Node3D>("__Animation Dummy_Armature");
		Entity = new Entity(this);


		CMovement = Entity.AddComponent<CMovement>();
		CStates = Entity.AddComponent<CStates>();
		CMainStates = Entity.AddComponent<CMainStates>();
		CActionVerifier = Entity.AddComponent<CActionVerifier>();
		CAnimations = Entity.AddComponent<CAnimations>();
		GetNode<EWeapon>("Fist").Init(this);
		CMainAnimations = Entity.AddComponent<CMainAnimations>();
		CCombat = Entity.AddComponent<CCombat>();

	}

	public override void _Process(double delta)
	{

		CStates.HandleStates(delta);
		CMainStates.HandleMainStates();
		CMainAnimations.MainAnimations();
	}

	public void OnHitMarker()
	{
		CCombat.OnHitMarker();
	}
}
