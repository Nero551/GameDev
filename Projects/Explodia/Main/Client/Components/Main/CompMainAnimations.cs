using Godot;
using System;

public partial class CompMainAnimations : Component
{
    IMainAnimatible mainAnimatible;

    protected override void OnInit()
    {
        mainAnimatible = Owner as IMainAnimatible;

    }

    public void MainAnimations()
    {
        if (Entity.GetComponent<CompMainStates>().MainState == CompMainStates.MainStates.Moving)
        {
            if (Entity.GetComponent<CompStates>().CheckState("Sprinting"))
            {
                Entity.GetComponent<CompAnimations>().PlayAnim("Default/Run", 3);
            }
            else
            {
                Entity.GetComponent<CompAnimations>().PlayAnim("Default/Walk", 3);
            }
        }
        else if (Entity.GetComponent<CompMainStates>().MainState == CompMainStates.MainStates.Idle)
        {
            if (mainAnimatible.ActiveHand == null)
            {
                Entity.GetComponent<CompAnimations>().PlayAnim("Default/Idle", 3);
            }
            else
            {
                if (mainAnimatible.ActiveHand.animationLibrary == null)
                {
                    Entity.GetComponent<CompAnimations>().PlayAnim("Default/Idle", 3);
                }
                else
                {
                    Entity.GetComponent<CompAnimations>().PlayAnim((string)mainAnimatible.ActiveHand.itemData["Name"] + "/" + "Idle", 3);
                }
            }
        }
    }
}
