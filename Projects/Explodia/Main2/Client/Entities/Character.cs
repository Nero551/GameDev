using System;
using Godot;

public partial class Character : CharacterBody3D, ICombatable, IMainAnimatible,ITransform3D, IVelocity, IIsOnFloor, IGetGravity, IMoveAndSlide
{
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
    public CBody cBody;

    protected ComponentHost componentHost;

    public override void _Ready()
    {
        componentHost = ComponentHost.Create(this);

        cBody = componentHost.AddComponent<CBody>();
        cHealth = componentHost.AddComponent<CHealth>();
        cMovement = componentHost.AddComponent<CMovement>();
        cStates = componentHost.AddComponent<CStates>();
        cMainStates = componentHost.AddComponent<CMainStates>();
        cActionVerifier = componentHost.AddComponent<CActionVerifier>();
        cAnimations = componentHost.AddComponent<CAnimations>();


        cMainAnimations = componentHost.AddComponent<CMainAnimations>();
        cForce = componentHost.AddComponent<CForce>();
        cCombat = componentHost.AddComponent<CCombat>();

        GetNodeOrNull<Weapon>("Fist").Init(this);
    }

    public override void _Process(double delta)
    {
        cStates.HandleStates(delta);
        cMainStates.HandleMainStates();
        cMainAnimations.MainAnimations();
    }

    public void OnHitMarker()
    {
        cCombat.OnHitMarker();
    }

    public override void _PhysicsProcess(double delta)
    {
        cMovement.ApplyBodyRotation(delta);
        cMovement.ApplyVelocity();
        cMovement.Gravity(delta);
    }


    public void OnAnimFinished(string animName)
    {
        cAnimations.OnAnimFinished(animName);
    }
}
