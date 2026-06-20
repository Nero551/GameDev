using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

public static class PlayersService
{
    public static BiDictionary<int, Entities.Player> Players = new();

    public static Entities.Player CreatePlayer(int userId)
    {
        Entities.Player player = Entity.Create<Entities.Player>();
        player.ConnectedNode?.Name = userId.ToString();
        Players.Add(userId, player);

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
            Players.GetByKey(userId).Destroy();
            Players.RemoveByKey(userId);
        }
    }

    public static Entities.Player GetPlayer(int userId)
    {
        if (Players.ContainsKey(userId))
        {
            return Players.GetByKey(userId);
        }
        return Entity.Create<Entities.Player>();
    }

    public static int GetUserId(Entities.Player player)
    {
        if (Players.ContainsValue(player))
        {
            return Players.GetByValue(player);
        }
        return default;
    }
}
