using System;
using Godot;

public partial class Player : CharacterBody3D
{
    public int UserId;
    public const float Speed = 2.5f;
    public const float JumpVelocity = 4.5f;
    [Export] Vector3 velocity;

    public override void _Ready()
    {
        base._Ready();

        EventService.Subscribe<RemoteEvents.MoveRequest>(OnMoveRequest);
        EventService.Subscribe<RemoteEvents.Position>(OnPosition);
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
                NetworkService.SendToServer<RemoteEvents.MoveRequest>(inputDir);
            }
        }
    }

    void OnMoveRequest(RemoteEvents.MoveRequest evnt)
    {
        Vector2 inputDir = evnt.Vec2;
        Move(Server.ClientInfos[evnt.SenderPeerId].Player, inputDir);
        NetworkService.SendToAllClients<RemoteEvents.Position>(
            Server.ClientInfos[evnt.SenderPeerId].UserId, Server.ClientInfos[evnt.SenderPeerId].Player.Velocity
            );
    }

    void OnPosition(RemoteEvents.Position evnt)
    {
        PlayersService.GetPlayer(evnt.UserId).Velocity = evnt.Vec3;
        PlayersService.GetPlayer(evnt.UserId).MoveAndSlide();
    }

}
