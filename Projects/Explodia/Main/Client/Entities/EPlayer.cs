using Godot;
using System;

public partial class EPlayer : Node3D
{
    public CCamera Ccamera;
    public CPlayerInput CplayerInput;
    public CPlayerMovement CplayerMovement;
    public CCharacter Ccharacter;

    private Entity Entity;

    public override void _Ready()
    {
        Entity = Entity.Create(this);
        Ccharacter = Entity.AddComponent<CCharacter>();
        Ccharacter.SpawnCharacter(this.Name);

        Ccamera = Entity.AddComponent<CCamera>();
        CplayerMovement = Entity.AddComponent<CPlayerMovement>();
        CplayerInput = Entity.AddComponent<CPlayerInput>();


    }

    public override void _Input(InputEvent @event)
    {
        Ccamera.RotateCamera(@event);
    }

    public override void _PhysicsProcess(double delta)
    {
        // Ccharacter.Character.Cmovement.Move(delta);
        // Ccamera.UpdateCam();
        // Ccharacter.Character.Cmovement.ApplyBodyRotation(delta);
        // Ccharacter.Character.Cmovement.ApplyVelocity();
        CplayerInput.PlayerInput(delta);
        Ccamera.ZoomCamera();
        CplayerMovement.MovementPhysics(delta);
    }

    public override void _Process(double delta)
    {
        GlobalPosition = Ccharacter.Character.GlobalPosition;
        base._Process(delta);
    }
}
