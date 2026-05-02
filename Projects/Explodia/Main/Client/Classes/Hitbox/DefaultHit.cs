using Godot;
using System;

public partial class Hitbox
{
	public void DefaultHit(Character Attacker, Godot.Collections.Dictionary itemData, Character targetHit)
	{
		targetHit.CurrentHealth -= (float)itemData["Damage"];
		Mathf.Max(0, targetHit.CurrentHealth);
		GD.Print(targetHit.CurrentHealth);

		//TODO make hitreactions animations
		//TODO VFX ,Animation all that stuff
	}
}
