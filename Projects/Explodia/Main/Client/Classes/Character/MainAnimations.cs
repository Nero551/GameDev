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
				PlayAnim("Run");
			}
			else if (CheckState("Walking") && IsMoving())
			{
				PlayAnim("Walk");
			}
			else
			{
				PlayAnim("Idle");
			}
		}
		else if (ActiveHand.animationLibrary != null)
		{
			//Play weapon Animations
			if (CheckState("Sprinting") && IsMoving())
			{
				PlayAnim("Run");
			}
			else if (CheckState("Walking") && IsMoving())
			{
				PlayAnim("Walk");
			}
			else
			{
				PlayAnimFromLibrary((string)ActiveHand.itemData["Name"], "Idle");
			}
		}
		else
		{
			if (CheckState("Sprinting") && IsMoving())
			{
				PlayAnim("Run");
			}
			else if (CheckState("Walking") && IsMoving())
			{
				PlayAnim("Walk");

			}
			else
			{
				PlayAnim("Idle");
			}
		}
	}
}
