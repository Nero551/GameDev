using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

public static class PlayersService
{
    public static Dictionary<int, Entities.Player> Players = [];

    public static Entities.Player CreatePlayer(int userId)
    {
        Entities.Player player = Entity.Create<Entities.Player>();
        player.ConnectedNode?.Name = userId.ToString();
        Players[userId] = player;

        return player;
    }

    public static List<Entities.Player> GetPlayers()
    {
        return [.. Players.Values];
    }

    public static List<int> GetAllUserIds()
    {
        return [.. Players.Keys];
    }

    public static void RemovePlayer(int userId)
    {
        if (Players.ContainsKey(userId))
        {
            Players[userId].Destroy();
            Players.Remove(userId);
        }
    }

    public static Entities.Player GetPlayer(int userId)
    {
        if (Players.ContainsKey(userId))
        {
            return Players[userId];
        }
        return Entity.Create<Entities.Player>();
    }
}
