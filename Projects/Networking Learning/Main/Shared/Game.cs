using System;
using Godot;
using Packets;

public partial class Game : Node3D
{
    public static Node3D game;
    // Called when the node enters the scene tree for the first time.
    public override void _EnterTree()
    {
        game = this;
        NetworkService.Init();
        Server.Start();
        Client.Start();
    }

    //*Note: u can add this to the launch args of the server to make it disable rendering:
        //* godot --headless Server

    public override void _Ready()
    {
    }

    public override void _Process(double delta)
    {
    }
}
