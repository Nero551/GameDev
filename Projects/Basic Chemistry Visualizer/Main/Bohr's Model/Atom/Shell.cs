using System;
using System.Reflection.Metadata;
using Godot;

public partial class Shell : Node3D
{
    [Export] float Velocity;
    [Export] int EnergyLevel;
    [Export] float Radius;
    [Export]
    int Electrons
    {
        get; set
        {
            if (EnergyLevel == 1)
            {
                field = Mathf.Clamp(value, 0, 2);
            }
            else
            {
                field = Mathf.Clamp(value, 0, 8);
            }
        }
    }

    public static Shell Create(Node parent, float radius, int energyLevel, int electrons)
    {
        var scene = GD.Load<PackedScene>("res://Main/Scenes/Shell.tscn");
        Shell shell = scene.Instantiate<Shell>();

        shell.Electrons = electrons;
        shell.EnergyLevel = energyLevel;
        shell.Name = $"Shell {energyLevel}";
        shell.Radius = radius;

        parent.GetNodeOrNull<Node3D>("Electrons").AddChild(shell);

        int angle = 0;
        for (int i = 1; i <= shell.Electrons; i++)
        {
            Electron electron = Electron.Create(shell);
			electron.Name = $"Electron{i}";
            Vector3 electronPos =
            new Vector3(Mathf.Cos(Mathf.DegToRad(angle)), 0, Mathf.Sin(Mathf.DegToRad(angle))) * radius;
            electron.Position = electronPos;
            angle += 360 / shell.Electrons;
        }

        return shell;
    }
    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(double delta)
    {
    }

    public override void _PhysicsProcess(double delta)
    {
        base._PhysicsProcess(delta);
        Rotation = new Vector3(Rotation.X, Rotation.Y + (float)delta * EnergyLevel * Mathf.E / Mathf.Pi, Rotation.Z);
    }
}
