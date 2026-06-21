using System;
using Godot;
using Microsoft.VisualBasic.FileIO;

public partial class CAI : Component
{
    public AIStates AIState;
    public Node3D Target;

    public enum AIStates
    {
        Attack,
        Follow,
        Wander,
        Idle,
    }

    public void SearchForTarget()
    {
        foreach (Player player in PlayersService.Players)
        {
            Vector3 pos = ComponentHost.GetInterface<ITransform3D>().GlobalPosition;
            Vector3 playerPos = player.cCharacter.Character.GlobalPosition;
            if ((playerPos - pos).Length() <= 50)
            {
                Target = player.cCharacter.Character;
                break;
            }
        }
    }

    public void Follow()
    {
        Vector3 pos = ComponentHost.GetInterface<ITransform3D>().GlobalPosition;
        Vector3 direction = (Target.GlobalPosition - pos).Normalized();
        ComponentHost.GetComponent<CMovement>().MoveDirection = new Vector2(direction.X, direction.Z);
        // ComponentHost.GetComponent<CStates>().AddState("Sprinting");
        ComponentHost.GetComponent<CMovement>().Move();
    }

    public void Attack()
    {
        ComponentHost.GetComponent<CCombat>().BasicAttack();
    }

    public void Idle()
    {

    }

    public void StateUpdater(double delta)
    {
        SearchForTarget();
        switch (AIState)
        {
            case AIStates.Attack:
                Attack();
                break;

            case AIStates.Follow:
                Follow();
                break;

            case AIStates.Idle:
                Idle();
                break;
        }    }
    //TODO AI functions go here (state updater , move , attack ,etc)
}
