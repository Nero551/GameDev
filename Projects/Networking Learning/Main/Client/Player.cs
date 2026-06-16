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
