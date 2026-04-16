using Godot;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;


public partial class StateManager : Node
{
	public Dictionary<string,double> ActiveStates  = new();

	// Called when the node enters the scene tree for the first time.
	public void Test()
	{
		GD.Print("Sick");		
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
}
