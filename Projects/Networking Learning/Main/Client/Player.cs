using System;
using Godot;

public partial class Player : CharacterBody3D
{
    public const float Speed = 5.0f;
    public const float JumpVelocity = 4.5f;
    [Export] Vector3 velocity;

    public override void _Ready()
    {
        base._Ready();
        EventService.Subscribe<Events.Remote.MoveRequest>(OnMoveRequest);
        EventService.Subscribe<Events.Remote.Position>(OnPosition);
    }

    private void Move(Vector2 inputDir)
    {
        Vector3 direction = (Transform.Basis * new Vector3(inputDir.X, 0, inputDir.Y)).Normalized();
        if (direction != Vector3.Zero)
        {
            velocity.X = direction.X * Speed;
            velocity.Z = direction.Z * Speed;
        }
        else
        {
            velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
            velocity.Z = Mathf.MoveToward(Velocity.Z, 0, Speed);
        }

        Velocity = velocity;
        MoveAndSlide();

    }

    public override void _PhysicsProcess(double delta)
    {
        velocity = Velocity;


        if (NetworkService.IsClient())
        {
            Vector2 inputDir = Input.GetVector("Left", "Right", "Forward", "Back");
            // Move(inputDir);
            NetworkService.SendToServer<Packets.MoveRequest>(inputDir);
        }
    }

    void OnMoveRequest(Events.Remote.MoveRequest evnt)
    {
        Vector2 inputDir = evnt.Vec2;
        Move(inputDir);
        NetworkService.SendToClient<Packets.Position>(evnt.SenderPeerId, Position);
    }

    void OnPosition(Events.Remote.Position evnt)
    {
        Position = evnt.Vec3;
    }

}
