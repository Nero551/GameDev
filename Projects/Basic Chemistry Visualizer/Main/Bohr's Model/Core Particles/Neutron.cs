using System;
using Godot;

public partial class Neutron : Particle
{
    // Called when the node enters the scene tree for the first time.
    public static Neutron Create(Node parent)
    {
        var scene = GD.Load<PackedScene>("res://Main/Scenes/Neutron.tscn");
        Neutron neutron = scene.Instantiate<Neutron>();

        parent.AddChild(neutron);
        return neutron;
    }

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
    }

}
