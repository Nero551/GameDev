using Godot;
using System;

public partial class Character
{
	public void MainAnimations()
	{
		if (MainState == MainStates.Moving)
		{
			if (CheckState("Sprinting"))
			{
				PlayAnim("Default/Run", 3);
			}
			else
			{
				PlayAnim("Default/Walk", 3);
			}
		}
		else if (MainState == MainStates.Idle)
		{
			if (ActiveHand == null)
			{
				PlayAnim("Default/Idle", 3);
			}
			else
			{
				if (ActiveHand.animationLibrary == null)
				{
					PlayAnim("Default/Idle", 3);
				}
				else
				{
					PlayAnim((string)ActiveHand.itemData["Name"] + "/" + "Idle", 3);
				}
			}
		}
	}
}
