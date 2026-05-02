using Godot;
using System;

public partial class Grid
{
    //TODO make global equations parser and handler

    public override void _Ready()
    {
        base._Ready();
        CreateGrid(20, 20, 20);
        LinearEquation(3, 4, 5);
        LinearEquation(4, -3, 5);
        QuadraticEquation(2, 4, 2);

        CreateCircle(new Vector3(5, 8, 0), 5);
        CreateTriangle(new Vector3(5, 8, 0), new Vector3(8, 8, 0), new Vector3(8, 12, 0));

        CreateTriangle(new Vector3(5, 8, 0), new Vector3(8, 8, 0), new Vector3(8, 4, 0));

        CreateLine("Triangle Median", new Vector3(8, 8, 0), (new Vector3(5, 8, 0) + new Vector3(8, 12, 0)) / 2);


        CreateLine("Triangle Median", new Vector3(8, 8, 0), (new Vector3(5, 8, 0) + new Vector3(8, 4, 0)) / 2);

    }

    public override void _Process(double delta)
    {
        base._Process(delta);
    }
}
