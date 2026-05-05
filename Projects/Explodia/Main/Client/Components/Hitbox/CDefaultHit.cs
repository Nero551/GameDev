using Godot;
using System;

public partial class CDefaultHit : Component
{
    public void DefaultHit(ECharacter Attacker, ECharacter targetHit, Godot.Collections.Dictionary itemData)
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
        //TODO add knockback
    }
}
