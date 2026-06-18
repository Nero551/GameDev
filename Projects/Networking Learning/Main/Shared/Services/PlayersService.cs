using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

public static class PlayersService
{
    public static Dictionary<int, Player> Players = [];

    public static Player CreatePlayer(int userId)
    {
        PackedScene scene = GD.Load<PackedScene>("res://Main/Shared/Scenes/player.tscn");
        Player player = scene.Instantiate<Player>();

        Players[userId] = player;
        Game.game.AddChild(player);
        return player;
    }

    public static List<Player> GetPlayers()
    {
        return [.. Players.Values];
    }

    public static void RemovePlayer(int userId)
    {
        if (Players.ContainsKey(userId))
        {
            Players[userId].QueueFree();
            Players.Remove(userId);
        }
    }
}
