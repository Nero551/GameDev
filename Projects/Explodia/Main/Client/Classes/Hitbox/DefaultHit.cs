using Godot;
using System;

public partial class Hitbox
{
	public void DefaultHit(Character Attacker, Godot.Collections.Dictionary itemData, Character targetHit)
	{
		targetHit.CurrentHealth -= (float)itemData["Damage"];
		GD.Print(targetHit.CurrentHealth);
		//TODO VFX ,Animation all that stuff
	}
}
