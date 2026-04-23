using Godot;
using Godot.NativeInterop;
using System.Collections.Generic;

public partial class Character
{
	private Dictionary<string, double> ActiveStates = new();

	private Godot.Collections.Dictionary stateData;
	public void InitStates()
	{
		stateData = PULib.JSONToCSharp("Main/Shared/Data/StateData");
	}
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

	public void RemoveState(params string[] stateNames)
	{
		foreach (var name in stateNames)
		{
			ActiveStates.Remove(name);
		}

	}

	public bool CheckState(params string[] stateNames)
	{
		foreach (var name in stateNames)
		{
			if (ActiveStates.ContainsKey(name))
			{
				return true;
			}
		}
		return false;
	}

	public void UpdateStatesDuration(double delta)
	{
		foreach (var key in ActiveStates.Keys)
		{
			if (ActiveStates[key] != double.MaxValue)
			{
				ActiveStates[key] -= delta;

				if (ActiveStates[key] <= 0)
					ActiveStates.Remove(key);
			}
				GD.Print(key);
		}
	}

	public void HandleStates(double delta)
	{
		foreach (var key in ActiveStates.Keys)
		{
			if (stateData.ContainsKey(key))
			{
				if (CurrentHealth <= 0)
				{
					AddState("Dead");
				}
				var data = (Godot.Collections.Dictionary)stateData[key];
				JumpPower = (float)data["JumpPower"];
				Speed = (float)data["Speed"];
				return;
			}
		}
	}
}
