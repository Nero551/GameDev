using Godot;
using System;

public partial class Grid
{
    public override void _Ready()
    {
        base._Ready();
        CreateGrid(20, 20, 20);
        CreateCircle(Origin, 5);
        Point A = CreatePoint("A", Origin);
        Point B = CreatePoint("B", new Vector3(3, 0, 0));
        Point C = CreatePoint("C", new Vector3(3, 4, 0));
        Line AB = CreateLine("AB", A.Position, B.Position);
        Line BC = CreateLine("BC", B.Position, C.Position);
        Line AC = CreateLine("AC", A.Position, C.Position);
    }

    public override void _Process(double delta)
    {
        base._Process(delta);
    }
}
