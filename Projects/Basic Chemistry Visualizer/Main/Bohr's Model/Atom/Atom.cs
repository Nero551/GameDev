using System;
using System.Collections.Generic;
using Godot;
using PULib;

public partial class Atom : Node3D
{
    private List<Electron> electrons = new();
    [Export] public Nucleus Nucleus;
    [Export] public int Electrons;
    [Export] public float Radius;
    [Export] public Godot.Collections.Dictionary<int, Shell> Shells;

    public static Atom Create(string name, Vector3 pos, Node parent, float radius, int protons, int neutrons, int electrons)
    {
        var scene = GD.Load<PackedScene>("res://Main/Scenes/Atom.tscn");
        Atom atom = scene.Instantiate<Atom>();
        atom.Position = pos;

        atom.Name = name;
        atom.Electrons = electrons;
        atom.Radius = radius;

        parent.AddChild(atom);
        atom.Nucleus = Nucleus.Create(atom, protons, neutrons);
        return atom;
    }

    public static Atom Create(Element element, Vector3 pos, Node parent)
    {
        var elementData = JSONHelper.JSONToCSharp($"Main/Chemical Elements/{element}");
        var scene = GD.Load<PackedScene>("res://Main/Scenes/Atom.tscn");
        Atom atom = scene.Instantiate<Atom>();
        atom.Position = pos;

        atom.Name = (string)elementData["Name"];
        atom.Radius = (float)elementData["AtomicRadius"];
        atom.Electrons = (int)elementData["Electrons"];

        parent.AddChild(atom);
        atom.Nucleus = Nucleus.Create(atom, (int)elementData["Protons"], (int)elementData["NeutronsApprox"]);
        return atom;
    }

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        CreateShells();
        float scale = Radius * Shells.Count * 0.115f;
        GetNodeOrNull<MeshInstance3D>("Barrier").Scale = new Vector3(scale, scale, scale);
    }

    public void CreateShells()
    {
        int MaxEnergyLevel = Mathf.CeilToInt(Electrons / 8);
        int remainingElectrons = Electrons;

        //Create First energy level
        if (remainingElectrons <= 2)
        {
            Shells[1] = Shell.Create(this, Radius, 1, remainingElectrons);
            return;
        }
        else
        {
            Shells[1] = Shell.Create(this, Radius, 1, 2);
            remainingElectrons -= 2;
        }

        //loop for the rest
        for (int i = 2; i <= MaxEnergyLevel + 2; i++)
        {
            if (remainingElectrons > 0)
            {
                //Shell class automatically limits electrons to 8 max
                Shells[i] = Shell.Create(this, i * Radius, i, remainingElectrons);

                if (remainingElectrons >= 8)
                {
                    remainingElectrons -= 8;
                }
                else
                {
                    remainingElectrons -= remainingElectrons;
                }
            }
            else
            {
                break;
            }
        }
    }
}
