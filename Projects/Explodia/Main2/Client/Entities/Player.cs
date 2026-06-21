using System;
using Godot;

public partial class Player : Node3D
{
    //TODO- later on i will def need a PlayersService to manage players.

    public CCamera cCamera;
    public CPlayerInput cPlayerInput;
    public CCharacter cCharacter;

    private ComponentHost componentHost;

    public override void _Ready()
    {
        componentHost = ComponentHost.Create(this);
        cCharacter = componentHost.AddComponent<CCharacter>();
        cCharacter.SpawnCharacter(this.Name);

        cCamera = componentHost.AddComponent<CCamera>();
        cPlayerInput = componentHost.AddComponent<CPlayerInput>();
    }

    public override void _Input(InputEvent @event)
    {
        cCamera.RotateCamera(@event);
    }

    public override void _PhysicsProcess(double delta)
    {
        cCharacter.Character.cMovement.Move();
        cCamera.ApplyCamRelativeMovement();
        cCamera.ZoomCamera();
    }

    public override void _Process(double delta)
    {
        GlobalPosition = cCharacter.Character.cBody.Root.GlobalPosition;
        cPlayerInput.PlayerInput(delta);
    }
}
