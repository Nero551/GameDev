using System;
using System.Collections.Generic;
using Godot;

public partial class Atom : Node3D
{
    private List<Electron> electrons = new();
    [Export] public Nucleus Nucleus;
    [Export] public int Electrons;
    [Export] public float Radius;

    public static Atom Create(string name, Vector3 pos, Node parent, float radius, int protons, int neutrons, int electrons)
    {
        var scene = GD.Load<PackedScene>("res://Main/Scenes/Atom.tscn");
        Atom atom = scene.Instantiate<Atom>();
        atom.Name = name;
        atom.Electrons = electrons;
        atom.Position = pos;
        atom.Radius = radius;

        for (int i = 1; i <= electrons; i++)
        {
            Electron electron = Electron.Create(atom.GetNodeOrNull<Node3D>("Electrons"));
            electron.Name = $"Electron{i}";
            atom.electrons.Add(electron);
        }

        parent.AddChild(atom);
        atom.Nucleus = Nucleus.Create(atom, protons, neutrons);
        return atom;

    }

    public static Atom Create(Element element, Vector3 pos, Node parent)
    {
        var elementData = PULib.JSONToCSharp($"Main/Chemical Elements/{element}");
        var scene = GD.Load<PackedScene>("res://Main/Scenes/Atom.tscn");
        Atom atom = scene.Instantiate<Atom>();
        atom.Name = (string)elementData["Name"];
        atom.Position = pos;
        atom.Radius = (float)elementData["AtomicRadius"];
        atom.Electrons = (int)elementData["Electrons"];

        for (int i = 1; i <= (int)elementData["Electrons"]; i++)
        {
            Electron electron = Electron.Create(atom.GetNodeOrNull<Node3D>("Electrons"));
            electron.Name = $"Electron{i}";
            atom.electrons.Add(electron);
        }

        parent.AddChild(atom);
        atom.Nucleus = Nucleus.Create(atom, (int)elementData["Protons"], (int)elementData["NeutronsApprox"]);
        return atom;

    }

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        int i = 0;
        foreach (Electron electron in electrons)
        {
            Vector3 electronPos =
            new Vector3(Mathf.Cos(Mathf.DegToRad(i)), 0, Mathf.Sin(Mathf.DegToRad(i))) * Radius * 3;
            electron.Position = electronPos;
            i += 360 / electrons.Count;
        }
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.


    public override void _PhysicsProcess(double delta)
    {
        base._PhysicsProcess(delta);
        GetNodeOrNull<Node3D>("Electrons").Rotation =
        new Vector3(GetNodeOrNull<Node3D>("Electrons").Rotation.X,
        GetNodeOrNull<Node3D>("Electrons").Rotation.Y + (float)delta * 10,
        GetNodeOrNull<Node3D>("Electrons").Rotation.Z);
    }
}
