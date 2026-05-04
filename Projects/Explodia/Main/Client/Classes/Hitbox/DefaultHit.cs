using Godot;
using System;

public partial class Hitbox
{
	public void DefaultHit(Character Attacker, Godot.Collections.Dictionary itemData, Character targetHit)
	{
		if (targetHit.compStates.CheckState("Invulnerable"))
		{
			return;
		}
		Attacker.compStates.AddState("In Combat", 30);
		targetHit.compStates.AddState("In Combat", 30);
		targetHit.compStates.AddState("Stunned", 0.2);
		//Damage
		targetHit.CurrentHealth -= (float)itemData["Damage"];
		Mathf.Max(0, targetHit.CurrentHealth);

		targetHit.compAnimations.PlayAnim("HitReactions/" + Attacker.compCombat.SwingNumber, 1);

		//TODO VFX ,Animation all that stuff
	}
}
