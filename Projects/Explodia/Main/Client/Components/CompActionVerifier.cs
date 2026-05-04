using Godot;
using System;

public partial class CompActionVerifier : Component
{

    public bool CanAttack()
    {
        if (Entity.GetComponent<CompStates>().CheckState("Attacking", "Blocking"))
        {
            return false;
        }
        return true;
    }
}
