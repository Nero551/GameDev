using System;
using Godot;

public partial class Game : Node3D
{
    public override void _Ready()
    {
        Input.MouseMode = Input.MouseModeEnum.Captured;

        // Atom.Create("Nydrogen", new Vector3(0, 0, 0), this, 1, 0, 1, 1);
        // Atom.Create("Pydrogen", new Vector3(5, 0, 0), this, 1, 1, 0, 1);
        // Atom.Create("Test", Vector3.Zero, this, 1.52f, 15, 15, 0);
        Atom.Create(Element.Oxygen, new Vector3(0, 0, 0), this);
    }

    public override void _Process(double delta)
    {
        if (Input.IsActionJustPressed("Mouse Capture"))
        {
            if (Input.MouseMode == Input.MouseModeEnum.Visible)
            {
                Input.MouseMode = Input.MouseModeEnum.Captured;
            }
            else
            {
                Input.MouseMode = Input.MouseModeEnum.Visible;

            }
        }
    }
}
