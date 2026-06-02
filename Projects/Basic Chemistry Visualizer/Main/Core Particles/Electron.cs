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
    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(double delta)
    {
    }
}
