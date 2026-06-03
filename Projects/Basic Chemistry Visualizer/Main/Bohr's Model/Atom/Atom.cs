using System;
using System.Collections.Generic;
using System.Linq;
using Godot;
using Godot.Collections;
using PULib;

public partial class Atom : Node3D
{
    [Export] public Nucleus Nucleus;
    [Export] public int Electrons;
    [Export] public Godot.Collections.Dictionary<int, Electron> ValenceElectrons = [];
    [Export] public float Radius;
    [Export] public Godot.Collections.Dictionary<int, Shell> Shells = [];
    [Export] public bool Stable;

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

        Scale = new Vector3(Radius, Radius, Radius);
        CreateShells();
        float scale = Radius * Shells.Count * 0.06f;
        GetNodeOrNull<MeshInstance3D>("Barrier").Scale = new Vector3(scale, scale, scale);
        AssignValenceElectrons();
    }

    private void CreateShells()
    {
        int MaxEnergyLevel = Mathf.CeilToInt(Electrons / 8);
        int remainingElectrons = Electrons;

        for (int i = 1; i <= MaxEnergyLevel + 3; i++)
        {
            if (remainingElectrons > 0)
            {
                int shellCapacity = 2 * (int)Mathf.Pow(i, 2);
                shellCapacity = Mathf.Clamp(shellCapacity, 0, 8);

                if (remainingElectrons >= shellCapacity)
                {
                    Shells[i] = Shell.Create(this, i * Radius, i, shellCapacity);
                    remainingElectrons -= shellCapacity;
                }
                else
                {
                    Shells[i] = Shell.Create(this, i * Radius, i, remainingElectrons);
                    remainingElectrons -= remainingElectrons;
                }
            }
            else
            {
                break;
            }
        }
    }

    private void AssignValenceElectrons()
    {
        int i = 1;
        foreach (Node node in Shells[Shells.Count].GetNode<Node3D>("Electrons").GetChildren())
        {
            if (node is Electron electron)
            {
                ValenceElectrons[i] = electron;
                i++;
            }
        }
    }

    public override void _Process(double delta)
    {
        base._Process(delta);
        Stable = (ValenceElectrons.Count == Shells[Shells.Count].Capacity);
    }
}
