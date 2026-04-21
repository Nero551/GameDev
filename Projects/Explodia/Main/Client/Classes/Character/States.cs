using Godot;
using System.Collections.Generic;

public partial class Character
{
	private Dictionary<string, double> ActiveStates = new();
	public void AddState(string stateName, double duration = -1)
	{
		if (duration > 0)
		{
			ActiveStates[stateName] = duration;

		}
		else
		{
			ActiveStates[stateName] = double.MaxValue;
		}
	}

	public void RemoveState(string stateName)
	{
		ActiveStates.Remove(stateName);

	}

	public bool CheckState(string stateName)
	{
		if (ActiveStates.ContainsKey(stateName))
		{
			return true;
		}
		return false;
	}

	public void UpdateStates(double delta)
	{
		foreach (var pair in ActiveStates)
		{
			if (pair.Value != double.MaxValue)
			{
				ActiveStates[pair.Key] -= delta;
			}
			GD.Print(pair.Key);
		}

	}

}
