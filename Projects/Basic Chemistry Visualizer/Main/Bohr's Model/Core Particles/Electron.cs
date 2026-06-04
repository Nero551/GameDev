using System;
using Godot;

public partial class Electron : Particle
{
    public static Electron Create(Node parent)
    {
        var scene = GD.Load<PackedScene>("res://Main/Scenes/Electron.tscn");
        Electron electron = scene.Instantiate<Electron>();

        parent.AddChild(electron);
        return electron;
    }
}
