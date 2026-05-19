using Godot;
using System;

public partial class CDefaultHit : Component
{


    public void DefaultHit(ECharacter Attacker, ECharacter targetHit, Godot.Collections.Dictionary itemData)
    {
        if (targetHit.cStates.CheckState("Invulnerable"))
        {
            return;
        }

        //States
        Attacker.cStates.AddState("In Combat", 30);
        targetHit.cStates.AddState("In Combat", 30);
        targetHit.cStates.AddState("Stunned", 0.2);

        //Damage
        targetHit.cHealth.CurrentHealth -= (float)itemData["Damage"];

        //Animations
        targetHit.cAnimations.PlayAnim("HitReactions/" + Attacker.cCombat.SwingNumber, 1);

        //Knockback
        if (Attacker.cCombat.SwingNumber == (int)itemData["Swings"])
        {
            targetHit.cForce.Knockback(new Vector3(0, 0, 10));
        }
        else
        {
            targetHit.cForce.Knockback(new Vector3(0, 0, 2));
            Attacker.cForce.Knockback(new Vector3(0, 0, 2));
        }

        //TODO VFX ,Animation all that stuff
        //TODO add knockback
    }
}
