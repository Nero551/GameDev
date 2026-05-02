using Godot;
using System;

public partial class Grid
{
    //TODO make global equations parser and handler

    public override void _Ready()
    {
        base._Ready();
        CreateGrid(20, 20, 20);

        // Vector3 a = Origin;
        // Vector3 b = new Vector3(4, 0, 0);
        // Vector3 c = new Vector3(4, 3, 0);

        // Point A = CreatePoint(a.ToString(), a);
        // Point B = CreatePoint(b.ToString(), b);
        // Point C = CreatePoint(c.ToString(), c);
        // Line AB = CreateLine(A.Position.ToString(), A.Position, B.Position);
        // Line BC = CreateLine(B.Position.ToString(), B.Position, C.Position);
        // Line AC = CreateLine(C.Position.ToString(), A.Position, C.Position);

        // GD.Print(Mathf.Atan(BC.Scale.Y / AB.Scale.Y));


        // float sin = BC.Scale.Y / AC.Scale.Y;
        // float cos = AB.Scale.Y / AC.Scale.Y;
        // float tan = BC.Scale.Y / AB.Scale.Y;

        // GD.Print("Sin: " + sin);
        // GD.Print("Cos: " + cos);
        // GD.Print("Tan: " + tan);

        // GD.Print("C: " + C.Position);
        // GD.Print(new Vector3(cos, sin, 0));
    }

    public override void _Process(double delta)
    {
        base._Process(delta);
    }
}
