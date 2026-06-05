using System;
using System.Collections.Generic;
using Godot;
using PULib;

public partial class CStates : Component
{

    public Dictionary<string, double> ActiveStates = new();

    private Godot.Collections.Dictionary stateData;
    protected override void OnInit()
    {
        stateData = JSONHelper.JSONToCSharp("Main/Shared/Data/StateData");
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
        foreach (string name in stateNames)
        {
            ActiveStates.Remove(name);
        }

    }

    public bool CheckState(params string[] stateNames)
    {
        foreach (string name in stateNames)
        {
            if (ActiveStates.ContainsKey(name))
            {
                return true;
            }
        }
        return false;
    }

    public void HandleStates(double delta)
    {

        float normalSpeed = 1;
        float normalJumpPower = 4.5f;
        foreach (string key in ActiveStates.Keys)
        {
            //Durations
            if (ActiveStates[key] != double.MaxValue)
            {
                ActiveStates[key] -= delta;

                if (ActiveStates[key] <= 0)
                    ActiveStates.Remove(key);
            }

            //Adjusting JumpPower and Speed
            if (stateData.ContainsKey(key))
            {
                Godot.Collections.Dictionary data = (Godot.Collections.Dictionary)stateData[key];
                if (data != null)
                {
                    // if (ComponentHost.GetComponent<CHealth>().CurrentHealth <= 0)
                    // {
                    //     AddState("Dead");
                    // }
                    normalJumpPower = (float)data["JumpPower"];
                    normalSpeed = (float)data["Speed"];
                    continue;
                }
            }
        }
        ComponentHost.GetComponent<CMovement>().Speed = normalSpeed;
        ComponentHost.GetComponent<CMovement>().JumpPower = normalJumpPower;
    }
}
