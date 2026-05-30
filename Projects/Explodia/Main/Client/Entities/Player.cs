using System;
using Godot;

public partial class Player : Node3D
{
    public CCamera cCamera;
    public CPlayerInput cPlayerInput;
    public CCharacter cCharacter;

    private Entity Entity;

    public override void _Ready()
    {
        Entity = Entity.Create(this);
        cCharacter = Entity.AddComponent<CCharacter>();
        cCharacter.SpawnCharacter(this.Name);

        cCamera = Entity.AddComponent<CCamera>();
        cPlayerInput = Entity.AddComponent<CPlayerInput>();
    }

    public override void _Input(InputEvent @event)
    {
        cCamera.RotateCamera(@event);
    }

    public override void _PhysicsProcess(double delta)
    {
        // cCharacter.Character.cMovement.Move();
        // cCamera.ApplyCamRelativeMovement();
        cCamera.ZoomCamera();
    }

    public override void _Process(double delta)
    {
        GlobalPosition = cCharacter.Character.cBody.Root.GlobalPosition;
        cPlayerInput.PlayerInput(delta);
    }
}
