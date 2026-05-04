using Godot;
using System;

public partial class EHitbox
{
	public void DefaultHit(ECharacter Attacker, Godot.Collections.Dictionary itemData, ECharacter targetHit)
	{
		if (targetHit.CStates.CheckState("Invulnerable"))
		{
			return;
		}
		Attacker.CStates.AddState("In Combat", 30);
		targetHit.CStates.AddState("In Combat", 30);
		targetHit.CStates.AddState("Stunned", 0.2);
		//Damage
		targetHit.CurrentHealth -= (float)itemData["Damage"];
		Mathf.Max(0, targetHit.CurrentHealth);

		targetHit.CAnimations.PlayAnim("HitReactions/" + Attacker.CCombat.SwingNumber, 1);

		//TODO VFX ,Animation all that stuff
	}
}
