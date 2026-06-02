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

        for (int i = 1; i <= Protons; i++)
        {
            Proton proton = Proton.Create(this);
            proton.Name = $"Proton{i}";
        }

        for (int i = 1; i <= Neutrons; i++)
        {
            Neutron neutron = Neutron.Create(this);
            neutron.Name = $"Neutron{i}";
        }
    }


    public override void _PhysicsProcess(double delta)
    {
        base._PhysicsProcess(delta);
        // foreach (Node node in this.GetChildren())
        // {
        //     Particle particle = (Particle)node;
        //     Area3D innerArea = particle.GetNodeOrNull<Area3D>("InnerArea3D");
        //     Area3D outerArea = particle.GetNodeOrNull<Area3D>("OuterArea3D");

        //     if (innerArea.HasOverlappingAreas())
        //     {
        //         foreach (Area3D overlapArea in innerArea.GetOverlappingAreas())
        //         {
        //             Particle other = overlapArea.GetParent<Particle>();

        //             Vector3 dir =
        //                 (particle.Position - other.Position).Normalized();

        //             particle.Position += dir * 0.1f;
        //         }
        //     }

        // }
        if (Protons + Neutrons > 1)
        {
            foreach (Node node in this.GetChildren())
            {
                Particle particle = (Particle)node;
                Area3D innerArea = particle.GetNodeOrNull<Area3D>("InnerArea3D");
                Area3D outerArea = particle.GetNodeOrNull<Area3D>("OuterArea3D");

                if (innerArea.HasOverlappingAreas() || !outerArea.HasOverlappingAreas())
                {
                    Vector3 dir = new Vector3(
                        (float)GD.RandRange(-1.0, 1.0),
                        (float)GD.RandRange(-1.0, 1.0),
                        (float)GD.RandRange(-1.0, 1.0)
                    );
                    particle.Position =
                    dir.Normalized() *
                    (particle.Scale.X) * GD.Randf() *
                    (Mathf.Abs(((Protons * Neutrons) / (Protons + Neutrons))) + 1);
                }
            }
        }
    }
}
