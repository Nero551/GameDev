using Godot;
using System;

public partial class MathWorld : Node2D
{
	public static MathWorld World;
    // Called when the node enters the scene tree for the first time.
    public override void _EnterTree()
    {
		World = this;
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
