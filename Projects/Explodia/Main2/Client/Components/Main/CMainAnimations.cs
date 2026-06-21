using System;
using Godot;

public partial class CMainAnimations : Component
{
    IMainAnimatible mainAnimatible;

    protected override void OnInit()
    {
        ComponentHost.GetComponent<CAnimations>().AddAnimLibrary(
            "HitReactions",
            ComponentHost.GetComponent<CAnimations>().LoadAnimLibrary("Main/Shared/Assets/Animations/HitReactions/HitReactions")
        );
        
        ComponentHost.GetComponent<CAnimations>().AddAnimLibrary(
            "Default",
            ComponentHost.GetComponent<CAnimations>().LoadAnimLibrary("Main/Shared/Assets/Animations/Default/Default")
        );
        mainAnimatible = ComponentHost.GetInterface<IMainAnimatible>();
    }

    public void MainAnimations()
    {
        if (ComponentHost.GetComponent<CMainStates>().MainState == CMainStates.MainStates.Moving)
        {
            if (ComponentHost.GetComponent<CStates>().CheckState("Sprinting"))
            {
                ComponentHost.GetComponent<CAnimations>().PlayAnim("Default/Run", 3);
            }
            else
            {
                ComponentHost.GetComponent<CAnimations>().PlayAnim("Default/Walk", 3);
            }
        }
        else if (ComponentHost.GetComponent<CMainStates>().MainState == CMainStates.MainStates.Idle)
        {
            if (mainAnimatible.ActiveHand == null)
            {
                ComponentHost.GetComponent<CAnimations>().PlayAnim("Default/Idle", 3);
            }
            else
            {
                if (mainAnimatible.ActiveHand.AnimationLibrary == null)
                {
                    ComponentHost.GetComponent<CAnimations>().PlayAnim("Default/Idle", 3);
                }
                else
                {
                    ComponentHost.GetComponent<CAnimations>().PlayAnim($"{(string)mainAnimatible.ActiveHand.ItemData["Name"]}/Idle", 3);
                }
            }
        }
    }
}
