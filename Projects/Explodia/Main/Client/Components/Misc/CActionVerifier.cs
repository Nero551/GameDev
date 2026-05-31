using System;
using Godot;

public partial class CActionVerifier : Component
{

    public bool CanAttack()
    {
        if (ComponentHost.GetComponent<CStates>().CheckState("Attacking"))
        {
            return false;
        }
        return true;
    }
}
