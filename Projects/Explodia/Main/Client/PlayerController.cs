using Godot;
using System;
using System.Collections.Generic;

public partial class PlayerController : Node
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		var ol = new List<int> { 1, 2, 5, 6 };
		var dic = new Dictionary<string, double>
		{
			{"A" , 5},
			{"B", 7.5}
		};
		var obj = GetNode<StateManager>("Node3D");
		obj.ActiveStates["Stunned"] = 4.5;
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		 StateManager lol = new  StateManager();
	}
}
