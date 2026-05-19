using Godot;
using System;

public partial class CMainAnimations : Component
{
    IMainAnimatible mainAnimatible;

    protected override void OnInit()
    {
        mainAnimatible = Entity.GetInterface<IMainAnimatible>();

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
            if (mainAnimatible.ActiveHand == null)
            {
                Entity.GetComponent<CAnimations>().PlayAnim("Default/Idle", 3);
            }
            else
            {
                if (mainAnimatible.ActiveHand.animationLibrary == null)
                {
                    Entity.GetComponent<CAnimations>().PlayAnim("Default/Idle", 3);
                }
                else
                {
                    Entity.GetComponent<CAnimations>().PlayAnim($"{(string)mainAnimatible.ActiveHand.itemData["Name"]}/Idle", 3);
                }
            }
        }
    }
}
