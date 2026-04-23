using Godot;
using System;

public partial class Hitbox
{
	public void BlockBreak(Character Attacker, float Damage, Character targetHit)
	{
		targetHit.CurrentHealth -= Damage;
		//TODO VFX Animation all that stuff
	}
}
