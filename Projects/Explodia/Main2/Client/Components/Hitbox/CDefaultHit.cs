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
        targetHit.cStates.AddState("Stunned", 0.4);
        //Damage
        targetHit.cHealth.CurrentHealth -= (float)itemData["Damage"];

        //Knockback
        Vector3 direction = -Attacker.Basis.Z;
        if (Attacker.cCombat.SwingNumber == (int)itemData["Swings"])
        {
            targetHit.cForce.Knockback(direction * 30);
        }
        else
        {
            targetHit.cForce.Knockback(direction * 2);
            Attacker.cForce.Pull(-direction * 2);
        }

        /*
        *Current Plan is: 
        * 1- godot shaders
        * 3- then we start on the server bs  
        */

        //TODO- learn how to use godot shaders and material to make good looking models in godot.

        //Animations, VFX & Sound
        targetHit.cAnimations.PlayAnim("HitReactions/" + Attacker.cCombat.SwingNumber, 1);
        VisualEffect.Spawn("Shared/Assets/VFX/HitImpact/HitImpact.tscn", targetHit.cBody.Root);
        AudioService.PlaySpatialSound("Shared/Assets/Audio/SFX/punch.wav", targetHit);
    }
}
