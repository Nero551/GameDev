using Godot;
using System;

public partial class Player : Node3D
{
    [Export] public Character Character;
    public override void _Ready()
    {
        SpawnCharacter();
        InitCamera();
    }

    public void SpawnCharacter()
    {
        if (Character == null)
        {
            PackedScene scene = GD.Load<PackedScene>("res://Main/Workspace/Character.tscn");
            Character = scene.Instantiate<Character>();
            Character.Name = this.Name;
            World.Characters.AddChild(Character);
        }
    }

    public override void _Input(InputEvent @event)
    {
        RotateCamera(@event);
    }

    public override void _PhysicsProcess(double delta)
    {
        GlobalPosition = Character.GlobalPosition;
        PlayerInput(delta);
        ZoomCamera();
        MovementPhysics(delta);
    }

    public override void _Process(double delta)
    {
        base._Process(delta);
    }
}
