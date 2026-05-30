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

        /*
        *Current Plan is: 
        * 1- doing the stuff down there in the todos
        * 2- making hit sounds
        * 3- making a slime monster that i can fight
        * 4- then we start on the server bs  
        */

        //TODO- make sound effects.
        //TODO- learn how to use godot shaders and material to make good looking models in godot.
        
        //VFX & Sound
        VisualService.Spawn("Shared/Assets/VFX/HitImpact/HitImpact.tscn", targetHit.cBody.Root);
        AudioService.PlaySpatialSound("Shared/Assets/Audio/SFX/punch.wav", targetHit);
    }
}
