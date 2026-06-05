using System;
using System.Linq;
using Godot;

public partial class Main : Node3D
{
    //TODO- learn godot networking, make networking serice wrapper to make using godot multiplayer easier.

    ENetMultiplayerPeer peer;

    public override void _Ready()
    {
        {
            Multiplayer.PeerConnected += OnPeerConnected;
            var args = OS.GetCmdlineArgs();

            if (args.Contains("--server"))
            {
                StandardMaterial3D material = new()
                {
                    AlbedoColor = Colors.Aqua
                };
                GetNode<MeshInstance3D>("Cube").MaterialOverride = material;
                StartHost();
            }
            else
            {
                StartClient();
            }
        }
    }

    private void StartHost()
    {
        peer = new ENetMultiplayerPeer();
        peer.CreateServer(7777);

        Multiplayer.MultiplayerPeer = peer;

        GD.Print("Server started");
    }

    private void StartClient()
    {
        peer = new ENetMultiplayerPeer();
        peer.CreateClient("127.0.0.1", 7777);

        Multiplayer.MultiplayerPeer = peer;

        GD.Print("Client connecting");
    }

    void OnPeerConnected(long id)
    {
        PackedScene scene = GD.Load<PackedScene>("res://player.tscn");
        CharacterBody3D player = scene.Instantiate<CharacterBody3D>();
        player.SetMultiplayerAuthority((int)id);
        AddChild(player);

        GD.Print("Spawned player: " + id);
    }
}
