using Godot;
using System.Collections.Generic;

public partial class Character
{
	public Dictionary<string, bool> ActiveStates = new();
	[Export] int lol = 5;
	public void AddState(string stateName)
	{
		ActiveStates[stateName] = true;
	}

	public void RemoveState(string stateName)
	{
		ActiveStates[stateName] = false;
	}


}
