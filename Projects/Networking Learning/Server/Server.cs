using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

public partial class Server : Node
{
    private int Port = 7777;
    private string IP = "127.0.0.1";
    private int MaxPlayers = 12;

    //TODO- learn godot networking, make networking serice wrapper to make using godot multiplayer easier.
    public static Dictionary<long, Player> Players = [];
    ENetMultiplayerPeer peer;

    public override void _Ready()
    {
        if (NetworkingService.IsServer())
        {
            StartServer();
        }
        else
        {
            Multiplayer.PeerConnected += OnClientConnected;
            ConnectClient();
        }
    }

    private void StartServer()
    {
        peer = new ENetMultiplayerPeer();
        peer.CreateServer(Port, MaxPlayers);
        Multiplayer.MultiplayerPeer = peer;

        GD.Print("Server Started");
    }

    private void ConnectClient()
    {
        if (Players.Count < MaxPlayers)
        {
            peer = new ENetMultiplayerPeer();
            peer.CreateClient(IP, Port);
            Multiplayer.MultiplayerPeer = peer;

            GD.Print("Client Connecting");
        }
        else
        {
            GD.Print("Server Full");
        }
    }

    void OnClientConnected(long id)
    {
        PackedScene scene = GD.Load<PackedScene>("res://player.tscn");
        Player player = scene.Instantiate<Player>();

        player.UserId = (int)id;
        player.SetMultiplayerAuthority(player.UserId);
        player.Name = player.UserId.ToString();
        Players.Add(player.UserId, player);

        Game.game.AddChild(player);
        GD.Print("Spawned player: " + player.UserId);
    }
}
