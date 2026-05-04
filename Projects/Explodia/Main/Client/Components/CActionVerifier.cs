using Godot;
using System;

public partial class CActionVerifier : Component
{

    public bool CanAttack()
    {
        if (Entity.GetComponent<CStates>().CheckState("Attacking", "Blocking"))
        {
            return false;
        }
        return true;
    }
}
