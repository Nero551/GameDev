using Godot;
using System;
using System.IO;

public partial class Csharp : Node
{
    public override void _Ready()
    {
        base._Ready();

        string data = File.ReadAllText("/home/nero551/Main/GameDev/Projects/Lab/Main/JsonToC#/JSON.json");

        Json jsonLoader = new Json();

        jsonLoader.Parse(data);
        System.Text.Json.
        Godot.Collections.Dictionary loadedData = (Godot.Collections.Dictionary)jsonLoader.Data;
    }
}
