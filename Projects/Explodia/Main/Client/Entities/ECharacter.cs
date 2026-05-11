using Godot;
using System;

public partial class ECharacter : CharacterBody3D, ICombatable, IMainAnimatible, IVelocity, IIsOnFloor, IGetGravity, IMoveAndSlide, IGlobalPosition
{
	[Export] public Node3D Rig { get; set; }
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
	public CKnockback Cknockback;
	public CPull Cpull;
	public CHealth Chealth;

	private Entity Entity;

	public override void _Ready()
	{
		Rig = GetNode<Node3D>("__Animation Dummy_Armature");
		Entity = Entity.Create(this);

		Chealth = Entity.AddComponent<CHealth>();
		Cmovement = Entity.AddComponent<CMovement>();
		Cstates = Entity.AddComponent<CStates>();
		CmainStates = Entity.AddComponent<CMainStates>();
		CactionVerifier = Entity.AddComponent<CActionVerifier>();
		Canimations = Entity.AddComponent<CAnimations>();
		CmainAnimations = Entity.AddComponent<CMainAnimations>();
		Cknockback = Entity.AddComponent<CKnockback>();
		Cpull = Entity.AddComponent<CPull>();
		Ccombat = Entity.AddComponent<CCombat>();

		GetNode<EWeapon>("Fist").Init(this);
	}

	public override void _Process(double delta)
	{
		Cstates.HandleStates(delta);
		CmainStates.HandleMainStates();
		CmainAnimations.MainAnimations();
		// MoveAndSlide();
	}

	public void OnHitMarker()
	{
		Ccombat.OnHitMarker();
	}

	public override void _PhysicsProcess(double delta)
	{
		// Cmovement.Move(delta);
		// Cmovement.Gravity(delta);
	}


	public void OnAnimFinished(string animName)
	{
		Canimations.OnAnimFinished(animName);
	}
}
