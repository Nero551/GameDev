using System;
using Godot;

public partial class Proton : Particle
{

    public static Proton Create(Node parent)
    {
        var scene = GD.Load<PackedScene>("res://Main/Scenes/Proton.tscn");
        Proton proton = scene.Instantiate<Proton>();

        parent.AddChild(proton);
        return proton;
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
