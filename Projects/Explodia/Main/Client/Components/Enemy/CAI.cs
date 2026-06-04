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
            Vector3 pos = ComponentHost.GetInterface<IGlobalPosition>().GlobalPosition;
            Vector3 playerPos = player.cCharacter.Character.GlobalPosition;
            if ((playerPos - pos).Length() <= 50)
            {
                Target = player.cCharacter.Character;
                break;
            }
        }
    }

    public void Move(double delta)
    {
        Vector3 pos = ComponentHost.GetInterface<IGlobalPosition>().GlobalPosition;
        Vector3 direction = (Target.GlobalPosition - pos).Normalized();
        ComponentHost.GetComponent<CMovement>().MoveDirection = new Vector2(direction.X, direction.Z);
        ComponentHost.GetComponent<CMovement>().Move();

        // ComponentHost.GetInterface<IGlobalPosition>().GlobalPosition += direction * (float)delta * 2;
    }

    public void Attack()
    {
        ComponentHost.GetComponent<CCombat>().BasicAttack();
    }

    public void StateUpdater(double delta)
    {
        SearchForTarget();

        if (Target == null)
        {
            AIState = AIStates.Idle;
            return;
        }

        if ((Target.GlobalPosition - ComponentHost.GetInterface<IGlobalPosition>().GlobalPosition).Length() <= 1)
        {
            Attack();
            return;
        }
        Move(delta);
        return;

    }
    //TODO AI functions go here (state updater , move , attack ,etc)
}
