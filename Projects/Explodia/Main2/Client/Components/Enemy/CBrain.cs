using System;
using Godot;

public partial class CBrain : Component
{
    public void Think()
    {

        if (ComponentHost.GetComponent<CAI>().Target == null)
        {
            ComponentHost.GetComponent<CAI>().AIState = CAI.AIStates.Idle;
            return;
        }

        if ((ComponentHost.GetComponent<CAI>().Target.GlobalPosition - ComponentHost.GetInterface<ITransform3D>().GlobalPosition).Length() <= 0.8f)
        {
            if (ComponentHost.GetComponent<CActionVerifier>().CanAttack())
            {
                ComponentHost.GetComponent<CAI>().AIState = CAI.AIStates.Attack;
            }
            return;
        }
        ComponentHost.GetComponent<CAI>().AIState = CAI.AIStates.Follow;
        return;
    }
}
