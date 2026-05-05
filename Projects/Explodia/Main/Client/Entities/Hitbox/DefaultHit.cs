using Godot;
using System;

public partial class EHitbox
{
	public void DefaultHit(ECharacter Attacker, Godot.Collections.Dictionary itemData, ECharacter targetHit)
	{
		if (targetHit.Cstates.CheckState("Invulnerable"))
		{
			return;
		}
		Attacker.Cstates.AddState("In Combat", 30);
		targetHit.Cstates.AddState("In Combat", 30);
		targetHit.Cstates.AddState("Stunned", 0.2);
		//Damage
		targetHit.CurrentHealth -= (float)itemData["Damage"];
		Mathf.Max(0, targetHit.CurrentHealth);

		targetHit.Canimations.PlayAnim("HitReactions/" + Attacker.Ccombat.SwingNumber, 1);

		//TODO VFX ,Animation all that stuff
	}
}
