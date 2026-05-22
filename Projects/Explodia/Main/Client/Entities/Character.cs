using Godot;
using System;

public partial class Character : CharacterBody3D, ICombatable, IMainAnimatible, IVelocity, IIsOnFloor, IGetGravity, IMoveAndSlide, IGlobalPosition
{
	[Export] public Node3D Rig { get; set; }
	[Export] public Item MainHand;
	[Export] public Item Offhand;
	[Export] public Item ActiveHand { get; set; }

	public CAnimations cAnimations;
	public CStates cStates;
	public CMainAnimations cMainAnimations;
	public CMainStates cMainStates;
	public CActionVerifier cActionVerifier;
	public CCombat cCombat;
	public CMovement cMovement;
	public CForce cForce;
	public CHealth cHealth;

	private Entity Entity;

	public override void _Ready()
	{
		
		Rig = GetNode<Node3D>("__Animation Dummy_Armature");
		Entity = Entity.Create(this);

		cHealth = Entity.AddComponent<CHealth>();
		cMovement = Entity.AddComponent<CMovement>();
		cStates = Entity.AddComponent<CStates>();
		cMainStates = Entity.AddComponent<CMainStates>();
		cActionVerifier = Entity.AddComponent<CActionVerifier>();
		cAnimations = Entity.AddComponent<CAnimations>();
		cMainAnimations = Entity.AddComponent<CMainAnimations>();
		cForce = Entity.AddComponent<CForce>();
		cCombat = Entity.AddComponent<CCombat>();

		GetNode<Weapon>("Fist").Init(this);
	}

	public override void _Process(double delta)
	{
		cStates.HandleStates(delta);
		cMainStates.HandleMainStates();
		cMainAnimations.MainAnimations();
		// MoveAndSlide();
	}

	public void OnHitMarker()
	{
		cCombat.OnHitMarker();
	}

	public override void _PhysicsProcess(double delta)
	{
		cMovement.ApplyVelocity();
		cMovement.Gravity(delta);
	}


	public void OnAnimFinished(string animName)
	{
		cAnimations.OnAnimFinished(animName);
	}
}
