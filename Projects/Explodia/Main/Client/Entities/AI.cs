using Godot;
using System;

public partial class AI : Character
{
    public enum AIStates
    {
        Attack,
        Follow,
        Wander,
        Idle,
    }
    [Export] public AIStates AIState;

    public override void _Process(double delta)
    {
        base._Process(delta);
        StateUpdater();
    }
    public void StateUpdater()
    {
    }
    //TODO AI functions go here (state updater , move , attack ,etc)
}
