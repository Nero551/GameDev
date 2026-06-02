using System;
using System.Collections.Generic;
using Godot;

public partial class Atom : Node3D
{
    private List<Electron> electrons = new();
    [Export] public Nucleus Nucleus;
    [Export] public int Electrons;

    public static Atom Create(string name, Node parent, int protons, int neutrons, int electrons)
    {
        var scene = GD.Load<PackedScene>("res://Main/Scenes/Atom.tscn");
        Atom atom = scene.Instantiate<Atom>();
        atom.Name = name;
        atom.Electrons = electrons;
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

    public static Atom Create(Element element, Node parent)
    {
        var elementData = PULib.JSONToCSharp($"Main/Chemical Elements/{element}");
        var scene = GD.Load<PackedScene>("res://Main/Scenes/Atom.tscn");
        Atom atom = scene.Instantiate<Atom>();
        atom.Name = (string)elementData["Name"];

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
        int count = 0;
        for (int i = 0; i < 360; i += 360 / electrons.Count)
        {
            Vector3 electronPos = new Vector3(Mathf.Cos(Mathf.DegToRad(i)), 0, Mathf.Sin(Mathf.DegToRad(i))) * 3;
            electrons[count].Position = electronPos;
            count++;
        }
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(double delta)
    {
    }


    public override void _PhysicsProcess(double delta)
    {
        base._PhysicsProcess(delta);
        GetNodeOrNull<Node3D>("Electrons").Rotation =
        new Vector3(GetNodeOrNull<Node3D>("Electrons").Rotation.X,
        GetNodeOrNull<Node3D>("Electrons").Rotation.Y + (float)delta * 10,
        GetNodeOrNull<Node3D>("Electrons").Rotation.Z);
    }
}
