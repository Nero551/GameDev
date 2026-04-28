using Godot;
using System;

public partial class Character
{
	public void MainAnimations()
	{
		if (ActiveHand == null)
		{
			if (CheckState("Sprinting") && IsMoving())
			{
				PlayAnim("Default/Run", 3);
			}
			else if (CheckState("Walking") && IsMoving())
			{
				PlayAnim("Default/Walk",3);
			}
			else
			{
				PlayAnim("Default/Idle",3);
			}
		}
		else if (ActiveHand.animationLibrary != null)
		{
			//Play weapon Animations
			if (CheckState("Sprinting") && IsMoving())
			{
				PlayAnim("Default/Run",3);
			}
			else if (CheckState("Walking") && IsMoving())
			{
				PlayAnim("Default/Walk",3);
			}
			else
			{
				PlayAnim((string)ActiveHand.itemData["Name"] +"/"+ "Idle",3);
			}
		}
		else
		{
			if (CheckState("Sprinting") && IsMoving())
			{
				PlayAnim("Default/Run",3);
			}
			else if (CheckState("Walking") && IsMoving())
			{
				PlayAnim("Default/Walk",3);

			}
			else
			{
				PlayAnim("Default/Idle",3);
			}
		}
	}
}
