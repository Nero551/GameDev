using System;
using Godot;

public partial class Nucleus : Node3D
{
    [Export] public int Protons;
    [Export] public int Neutrons;

    public static Nucleus Create(Node parent, int protons, int neutrons)
    {
        var scene = GD.Load<PackedScene>("res://Main/Scenes/Nucleus.tscn");
        Nucleus nucleus = scene.Instantiate<Nucleus>();

        nucleus.Protons = protons;
        nucleus.Neutrons = neutrons;

        parent.AddChild(nucleus);
        return nucleus;
    }

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        CreateNeutrons();
        CreateProtons();
    }

    private void CreateProtons()
    {
        for (int i = 1; i <= Protons; i++)
        {
            Proton proton = Proton.Create(this);
            proton.Name = $"Proton{i}";
            proton.Position = ParticlePosition(i, Protons + Neutrons);
        }
    }

    private void CreateNeutrons()
    {
        for (int i = 1; i <= Neutrons; i++)
        {
            Neutron neutron = Neutron.Create(this);
            neutron.Name = $"Neutron{i}";
            neutron.Position = ParticlePosition(i + Protons, Protons + Neutrons);
        }
    }

    private Vector3 ParticlePosition(int i, int total)
    {
        float t = (float)i / (float)total;

        float inclination = Mathf.Acos(1 - 2 * t);
        float azimuth = Mathf.Tau * i * 0.618033f; // golden ratio
        return new Vector3(
            Mathf.Sin(inclination) * Mathf.Cos(azimuth),
            Mathf.Cos(inclination),
            Mathf.Sin(inclination) * Mathf.Sin(azimuth)
        );
    }
}
