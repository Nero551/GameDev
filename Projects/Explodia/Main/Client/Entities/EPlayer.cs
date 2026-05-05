using Godot;
using System;

public partial class EPlayer : Node3D, ICamerable, IInputible, IPlayerMovable
{
    [Export] public ECharacter Character { get; set; }
    public SpringArm3D SpringArm { get; set; }

    public CCamera Ccamera;
    public CPlayerInput CplayerInput;
    public CPlayerMovement CplayerMovement;

    public Entity Entity;

    public override void _Ready()
    {
        SpawnCharacter();
        Entity = new Entity(this);
        SpringArm = GetNode<SpringArm3D>("SpringArm3D");

        Ccamera = Entity.AddComponent<CCamera>();
        CplayerInput = Entity.AddComponent<CPlayerInput>();
        CplayerMovement = Entity.AddComponent<CPlayerMovement>();


    }

    public void SpawnCharacter()
    {
        if (Character == null)
        {
            PackedScene scene = GD.Load<PackedScene>("res://Main/Workspace/Character.tscn");
            Character = scene.Instantiate<ECharacter>();
            Character.Name = this.Name;
            World.Characters.AddChild(Character);
        }
    }

    public override void _Input(InputEvent @event)
    {
        Ccamera.RotateCamera(@event);
    }

    public override void _PhysicsProcess(double delta)
    {
        CplayerInput.PlayerInput(delta);
        Ccamera.ZoomCamera();
        CplayerMovement.MovementPhysics(delta);
    }

    public override void _Process(double delta)
    {
        GlobalPosition = Character.GlobalPosition;
        base._Process(delta);
    }
}
