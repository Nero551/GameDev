using System;
using Godot;

public partial class CDefaultHit : Component
{


    public void DefaultHit(Character Attacker, Character targetHit, Godot.Collections.Dictionary itemData)
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
            targetHit.cForce.Knockback(new Vector3(0, 0, 2));
        }
        else
        {
            targetHit.cForce.Knockback(new Vector3(0, 0, 1));
            Attacker.cForce.Knockback(new Vector3(0, 0, 1));
        }

        //VFX & Sound
        VisualService.Spawn("Shared/Assets/VFX/HitImpact/HitImpact.tscn", targetHit, targetHit.GlobalPosition + new Vector3(0, 0.7f, 0));
        AudioService.PlaySpatialSound("Shared/Assets/Audio/SFX/AirBlow.mp3", targetHit);
    }
}
