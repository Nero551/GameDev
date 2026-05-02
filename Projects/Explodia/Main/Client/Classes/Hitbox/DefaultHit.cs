using Godot;
using System;

public partial class Hitbox
{
	public void DefaultHit(Character Attacker, Godot.Collections.Dictionary itemData, Character targetHit)
	{
		if (targetHit.CheckState("Invulnerable"))
		{
			return;
		}
		Attacker.AddState("In Combat", 30);
		targetHit.AddState("In Combat", 30);
		targetHit.AddState("Stunned", 0.2);
		//Damage
		targetHit.CurrentHealth -= (float)itemData["Damage"];
		Mathf.Max(0, targetHit.CurrentHealth);

		targetHit.PlayAnim("HitReactions/" + Attacker.SwingNumber, 1);

		//TODO VFX ,Animation all that stuff
	}
}
