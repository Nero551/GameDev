using System;
using System.Threading.Tasks;
using Godot;

public partial class Player : CharacterBody3D
{
    public int UserId;
    public const float Speed = 20f;
    [Export] Vector3 velocity;

    private Vector3 TargetPosition;
    private int TargetPlayerId;

    public override void _Ready()
    {
        base._Ready();

        EventService.Subscribe<RemoteEvents.MoveRequest>(OnMoveRequest);
        EventService.Subscribe<RemoteEvents.Position>(OnPosition);
    }

    private void Move(Player player, Vector2 inputDir)
    {
        velocity = Velocity;
        Vector3 direction = (player.Transform.Basis * new Vector3(inputDir.X, -inputDir.Y, 0)).Normalized();
        if (direction != Vector3.Zero)
        {
            velocity.X = direction.X * Speed;
            velocity.Y = direction.Y * Speed;
        }
        else
        {
            velocity.X = Mathf.MoveToward(velocity.X, 0, Speed);
            velocity.Y = Mathf.MoveToward(velocity.Y, 0, Speed);
        }

        player.Velocity = velocity;
        player.MoveAndSlide();
    }

    private double _timeSinceLastSend;

    public override void _PhysicsProcess(double delta)
    {
        if (TargetPlayerId != default && TargetPosition != default)
        {
            PlayersService.GetPlayer(TargetPlayerId).Position = 
                PlayersService.GetPlayer(TargetPlayerId).Position.Lerp(TargetPosition, 0.1f);
        }

        if (!NetworkService.IsClient())
            return;

        _timeSinceLastSend += delta;

        if (_timeSinceLastSend < 0.1)
            return;

        _timeSinceLastSend = 0;

        Vector2 inputDir = Input.GetVector(
            "Left",
            "Right",
            "Forward",
            "Back"
        );

        if (inputDir != Vector2.Zero)
            NetworkService.SendToServer<RemoteEvents.MoveRequest>(inputDir);
    }

    void OnMoveRequest(RemoteEvents.MoveRequest evnt)
    {
        Vector2 inputDir = evnt.Vec2;
        Move(Server.ClientInfos[evnt.SenderPeerId].Player, inputDir);

        NetworkService.SendToAllClients<RemoteEvents.Position>(
            Server.ClientInfos[evnt.SenderPeerId].UserId, Server.ClientInfos[evnt.SenderPeerId].Player.Position
            );
    }

    void OnPosition(RemoteEvents.Position evnt)
    {
        TargetPosition = evnt.Vec3;
        TargetPlayerId = evnt.UserId;
    }
}
