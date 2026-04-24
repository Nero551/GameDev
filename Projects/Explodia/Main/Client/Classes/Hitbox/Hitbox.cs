using Godot;
using System;
using System.Collections.Generic;

public partial class Hitbox : Area3D
{

	private HashSet<Character> hitTargets = new();

	private Godot.Collections.Dictionary Data;
	public Character Attacker;
	public void OnBodyEntered(Node3D body)
	{
		Character targetHit = body.GetOwner<Character>();

		if (targetHit != null && targetHit is Character && targetHit != Attacker)
		{
			if (hitTargets.Contains(targetHit))
			{
				return;
			}
			hitTargets.Add(targetHit);

			//Actual Hit Logic Here pls
			//TODO Still Under Development
			if (targetHit.CheckState("Blocking"))
			{
				if (false)
				{
					// BlockBreak(Attacker,Data,targetHit);
				}
				else
				{
					// BlockedHit(Attacker, Data, targetHit);
				}
			}
			else
			{
				DefaultHit(Attacker, Data, targetHit);
			}
		}
	}

	public void Init(Vector3 size, Character attacker)
	{
		SetHitboxSize(size);
		Attacker = attacker;
		Data = Attacker.ActiveHand.itemData;
	}

	public void SetHitboxSize(Vector3 size)
	{
		var shape = (BoxShape3D)GetNode<CollisionShape3D>("CollisionShape3D").Shape;
		shape.Size = size;
	}
}
