using Godot;
using System;

public partial class CMainAnimations : Component
{
    IMainAnimatible IMainAnimatible;

    protected override void OnInit()
    {
        IMainAnimatible = Owner as IMainAnimatible;

    }

    public void MainAnimations()
    {
        if (Entity.GetComponent<CMainStates>().MainState == CMainStates.MainStates.Moving)
        {
            if (Entity.GetComponent<CStates>().CheckState("Sprinting"))
            {
                Entity.GetComponent<CAnimations>().PlayAnim("Default/Run", 3);
            }
            else
            {
                Entity.GetComponent<CAnimations>().PlayAnim("Default/Walk", 3);
            }
        }
        else if (Entity.GetComponent<CMainStates>().MainState == CMainStates.MainStates.Idle)
        {
            if (IMainAnimatible.ActiveHand == null)
            {
                Entity.GetComponent<CAnimations>().PlayAnim("Default/Idle", 3);
            }
            else
            {
                if (IMainAnimatible.ActiveHand.animationLibrary == null)
                {
                    Entity.GetComponent<CAnimations>().PlayAnim("Default/Idle", 3);
                }
                else
                {
                    Entity.GetComponent<CAnimations>().PlayAnim((string)IMainAnimatible.ActiveHand.itemData["Name"] + "/" + "Idle", 3);
                }
            }
        }
    }
}
