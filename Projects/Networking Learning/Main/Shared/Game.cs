using System;
using Godot;
using Packets;

public partial class Game : Node3D
{
    public static Node3D game;
    // Called when the node enters the scene tree for the first time.
    public override void _EnterTree()
    {
        NetworkService.Init();
        game = this;
    }

    public override void _Ready()
    {

        Server.Start();
        Client.Start();
    }

    public override void _Process(double delta)
    {
        // NetworkService.SendToClient<Packets.TestPacket>(256,6);
        // NetworkService.SendToServer<Packets.TestPacket>(6);
        // NetworkService.SendToAllClients<Packets.TestPacket>(6);

    }
}
