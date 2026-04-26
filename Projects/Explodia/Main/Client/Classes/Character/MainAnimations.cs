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
				PlayAnimFromLibrary("Default","Run");
			}
			else if (CheckState("Walking") && IsMoving())
			{
				PlayAnimFromLibrary("Default", "Walk");
			}
			else
			{
				PlayAnimFromLibrary("Default", "Idle");
			}
		}
		else if (ActiveHand.animationLibrary != null)
		{
			//Play weapon Animations
			if (CheckState("Sprinting") && IsMoving())
			{
				PlayAnimFromLibrary("Default", "Run");
			}
			else if (CheckState("Walking") && IsMoving())
			{
				PlayAnimFromLibrary("Default", "Walk");
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
				PlayAnimFromLibrary("Default", "Run");
			}
			else if (CheckState("Walking") && IsMoving())
			{
				PlayAnimFromLibrary("Default", "Walk");

			}
			else
			{
				PlayAnimFromLibrary("Default", "Idle");
			}
		}
	}
}
