using Godot;
using System;
using System.Collections.Generic;
using System.Security.Cryptography.X509Certificates;

public partial class Hitbox : Area3D
{
	private Dictionary<Character, int> hitTargets = new();

	private Godot.Collections.Dictionary Data;
	public Character Attacker;
	public void OnBodyEntered(Node3D body)
	{
		Character targetHit = body.GetOwner<Character>();

		if (targetHit != null && targetHit is Character && targetHit != Attacker)
		{
			if (hitTargets.ContainsKey(targetHit))
			{
				if (hitTargets[targetHit] >= (int)Data["Hits"])
				{
					return;
				}
				else
				{
					hitTargets[targetHit]++;
				}
			}
			else
			{
				hitTargets.Add(targetHit, 1);
			}

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

	public void Init(Vector3 position, Vector3 size, Character attacker)
	{
		GD.Print(position);
		SetHitboxSize(size);
		SetHitboxPosition(position);
		Attacker = attacker;
		Data = Attacker.ActiveHand.itemData;
	}

	public void SetHitboxPosition(Vector3 position)
	{
		Position = position;
	}
	public void SetHitboxSize(Vector3 size)
	{
		var shape = (BoxShape3D)GetNode<CollisionShape3D>("CollisionShape3D").Shape;
		shape.Size = size;
	}
}
