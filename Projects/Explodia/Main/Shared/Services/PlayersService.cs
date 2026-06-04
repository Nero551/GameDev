using System;
using System.Collections.Generic;
using Godot;

public class PlayersService : Service
{
    public static List<Player> Players = [];

    public static Player Spawn(string name)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/Workspace/Player.tscn");
        Player player = scene.Instantiate<Player>();

        player.Name = name;
		
        Players.Add(player);

        Game.Players.AddChild(player);
        return player;
    }
}
