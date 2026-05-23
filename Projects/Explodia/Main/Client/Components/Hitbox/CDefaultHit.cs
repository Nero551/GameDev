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

        //Todo- need way to attach vfx to specific parts of his body
        //Todo- probably with marker3D that marks the parts on the body like attachment points.
        //Todo- so they work with multiple entity types(player , slime)
        //TODO- basically i need to rework the character, its setup was trash anyway.
        //TODO- rethink how characters and monsters would even work.

        //TODO- i think a good starting point is making the model for the slime then figuring out the rest.
        //VFX & Sound
        VisualService.Spawn("Shared/Assets/VFX/HitImpact/HitImpact.tscn", targetHit, targetHit.GlobalPosition + new Vector3(0, 0.7f, 0));
        AudioService.PlaySpatialSound("Shared/Assets/Audio/SFX/AirBlow.mp3", targetHit);
    }
}
