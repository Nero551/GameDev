using System;
using Events.Remote;
using Godot;

public partial class Player : CharacterBody3D
{
    public int UserId;
    public const float Speed = 5.0f;
    public const float JumpVelocity = 4.5f;
    [Export] Vector3 velocity;

    public override void _Ready()
    {
        base._Ready();

        EventService.Subscribe<Events.Remote.MoveRequest>(OnMoveRequest);
        EventService.Subscribe<Events.Remote.Position>(OnPosition);
    }

    private void Move(Player player, Vector2 inputDir)
    {
        Vector3 direction = (player.Transform.Basis * new Vector3(inputDir.X, -inputDir.Y, 0)).Normalized();
        if (direction != Vector3.Zero)
        {
            velocity.X = direction.X * Speed;
            velocity.Y = direction.Y * Speed;
        }
        else
        {
            velocity.X = Mathf.MoveToward(player.Velocity.X, 0, Speed);
            velocity.Y = Mathf.MoveToward(player.Velocity.Y, 0, Speed);
        }

        player.Velocity = velocity;
        player.MoveAndSlide();

    }

    public override void _PhysicsProcess(double delta)
    {

        velocity = Velocity;

        if (NetworkService.IsClient())
        {
            Vector2 inputDir = Input.GetVector("Left", "Right", "Forward", "Back");
            if (inputDir != Vector2.Zero)
            {
                NetworkService.SendToServer<Packets.MoveRequest>(inputDir);
            }
        }
    }

    void OnMoveRequest(Events.Remote.MoveRequest evnt)
    {
        Vector2 inputDir = evnt.Vec2;
        Move(Server.ClientInfos[evnt.SenderPeerId].Player, inputDir);
        NetworkService.SendToAllClients<Packets.Position>(
            Server.ClientInfos[evnt.SenderPeerId].UserId, Server.ClientInfos[evnt.SenderPeerId].Player.Position
            );
    }

    void OnPosition(Events.Remote.Position evnt)
    {
        PlayersService.GetPlayer(evnt.UserId).Position = evnt.Vec3;
    }

}
