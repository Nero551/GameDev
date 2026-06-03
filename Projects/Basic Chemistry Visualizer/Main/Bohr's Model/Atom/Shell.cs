using System;
using System.Reflection.Metadata;
using Godot;

public partial class Shell : Node3D
{
    [Export] public int EnergyLevel;
    [Export] public float Radius;
    [Export] public int Capacity;
    [Export] int Electrons;

    private Vector3 RotationSpeed;

    public static Shell Create(Node parent, float radius, int energyLevel, int electrons)
    {
        var scene = GD.Load<PackedScene>("res://Main/Scenes/Shell.tscn");
        Shell shell = scene.Instantiate<Shell>();

        shell.Electrons = electrons;
        shell.EnergyLevel = energyLevel;
        shell.Name = $"Shell {energyLevel}";
        shell.Radius = radius;
        shell.Capacity = Mathf.Clamp(2 * (int)Mathf.Pow(energyLevel, 2), 0, 8);

        parent.GetNodeOrNull<Node3D>("Shells").AddChild(shell);

        int angle = 0;
        for (int i = 1; i <= shell.Electrons; i++)
        {
            Electron electron = Electron.Create(shell.GetNodeOrNull<Node3D>("Electrons"));
            electron.Name = $"Electron{i}";
            Vector3 electronPos = new Vector3(
                Mathf.Cos(Mathf.DegToRad(angle)),
                0,
                Mathf.Sin(Mathf.DegToRad(angle))
            ) * radius * 0.8f;

            electron.Position = electronPos;
            angle += 360 / shell.Electrons;
        }

        return shell;
    }
    public override void _Ready()
    {
        Rotation = new Vector3(
            EnergyLevel * 20,
            EnergyLevel * 35,
            0
        );
    }

    public override void _Process(double delta)
    {
        Rotation = new Vector3(EnergyLevel * 8, 0, EnergyLevel * 8);
    }

    public override void _PhysicsProcess(double delta)
    {
        float value = (float)delta;
        base._PhysicsProcess(delta);
        GetNodeOrNull<Node3D>("Electrons").RotateY(value);
    }
}
