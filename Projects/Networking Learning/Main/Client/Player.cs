using System;
using Events;
using Godot;

public partial class Player : CharacterBody3D
{
    [Export] public int UserId;
    [Export] public ENetPacketPeer Client;
    public const float Speed = 5.0f;
    public const float JumpVelocity = 4.5f;
    [Export] Vector3 velocity;


    public void Start()
    {
        NetworkService.Connection = new ENetConnection();
        Error error = NetworkService.Connection.CreateHost(1);
        if (error != default)
        {
            GD.Print($"Client Failed To Start: {error}");
            NetworkService.Connection = null;
            return;
        }
        GD.Print("Client Started");
        NetworkService.Connection.ConnectToHost(Server.IP, Server.Port);
    }

    void HandlePackets()
    {
        if (!NetworkService.IsClient())
            return;

        var packetEvent = NetworkService.Connection.Service();
        ENetConnection.EventType eventType = packetEvent[0].As<ENetConnection.EventType>();
        var peer = packetEvent[1].As<ENetPacketPeer>();

        switch (eventType)
        {
            case ENetConnection.EventType.Error:
                GD.PushWarning("Packet Resulted in Unknown Error!");
                break;
            case ENetConnection.EventType.Connect:
                ConnectedToServer();
                break;
            case ENetConnection.EventType.Disconnect:
                DisconnectedFromServer();
                return;
            case ENetConnection.EventType.Receive:
                EventService.Fire(new Events.ClientRecievedPacket(peer.GetPacket()));
                break;
            default:
                break;
        }
        packetEvent = NetworkService.Connection.Service();
        eventType = packetEvent[0].As<ENetConnection.EventType>();
    }

    void DisconnectedFromServer()
    {
        GD.Print("Disconnected To Server");
        EventService.Fire(new DisconnectedFromServer());
    }

    void ConnectedToServer()
    {
        GD.Print("Connected To Server");
        EventService.Fire(new ConnectedToServer());
    }

    public override void _Process(double delta)
    {
        base._Process(delta);
        HandlePackets();

    }

    public override void _PhysicsProcess(double delta)
    {
        velocity = Velocity;


        // Get the input direction and handle the movement/deceleration.
        // As good practice, you should replace UI actions with custom gameplay actions.
        Vector2 inputDir = Input.GetVector("Left", "Right", "Forward", "Back");

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
        Packet.Create<Packets.TestPacket>().Send(1, []);
    }
}
