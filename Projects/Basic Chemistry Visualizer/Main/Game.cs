using System;
using Godot;

public partial class Game : Node3D
{
    public override void _Ready()
    {
        Input.MouseMode = Input.MouseModeEnum.Captured;

        // Atom.Create("Nydrogen", new Vector3(0, 0, 0), 1.5f, this, 8, 8, 1000);
        // Atom.Create(Element.Sodium, Vector3.Zero, this);
        // Atom.Create(Element.Chlorine, new Vector3(1,0,0), this);
        // Atom.Create(Element.Oxygen, Vector3.Zero, this);

        Atom.Create(Element.Uranium, new Vector3(1, 0, 0), this);
        
        // for (int i = 0; i < 250; i++)
        // {
        //     Atom.Create(Element.Oxygen, Vector3.Zero, this);
        // }
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
