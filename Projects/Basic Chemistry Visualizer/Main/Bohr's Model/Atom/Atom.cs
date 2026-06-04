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
    [Export] public Godot.Collections.Dictionary<int, Shell> Shells = [];
    [Export] public bool Stable;
    [Export] public Color CPKColor;

    public static Atom Create(string name, Vector3 pos, Node parent, int protons, int neutrons, int electrons, Color color = default)
    {
        var scene = GD.Load<PackedScene>("res://Main/Scenes/Atom.tscn");
        Atom atom = scene.Instantiate<Atom>();
        atom.Position = pos;

        atom.Name = name;
        atom.Electrons = electrons;
        atom.CPKColor = color == default ? Colors.Green : color;

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
        atom.Electrons = (int)elementData["Electrons"];
        atom.CPKColor = new Color((string)elementData["CPKColor"]);

        parent.AddChild(atom);
        atom.Nucleus = Nucleus.Create(atom, (int)elementData["Protons"], (int)elementData["NeutronsApprox"]);
        return atom;
    }

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        CreateShells();
        float scale = 1.25f * Shells.Count * 0.11f;
        GetNodeOrNull<MeshInstance3D>("Barrier").Scale = new Vector3(scale, scale, scale);

        if (GetNodeOrNull<MeshInstance3D>("Barrier").GetActiveMaterial(0) is StandardMaterial3D mat)
        {
            mat = (StandardMaterial3D)mat.Duplicate(); // important (don’t edit shared material)
            mat.AlbedoColor = CPKColor;
            GetNodeOrNull<MeshInstance3D>("Barrier").MaterialOverride = mat;
        }
        AssignValenceElectrons();
    }

    private void CreateShells()
    {
        int MaxEnergyLevel = Mathf.CeilToInt(Electrons / 8);
        int remainingElectrons = Electrons;

        for (int i = 1; i <= MaxEnergyLevel + 2; i++)
        {
            if (remainingElectrons > 0)
            {
                int shellCapacity = 2 * (int)Mathf.Pow(i, 2);
                shellCapacity = Mathf.Clamp(shellCapacity, 0, 8);

                if (remainingElectrons >= shellCapacity)
                {
                    Shells[i] = Shell.Create(this, i * 1.25f, i, shellCapacity);
                    remainingElectrons -= shellCapacity;
                }
                else
                {
                    Shells[i] = Shell.Create(this, i * 1.25f, i, remainingElectrons);
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
