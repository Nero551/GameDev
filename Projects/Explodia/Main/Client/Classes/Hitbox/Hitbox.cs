using Godot;
using System;
using System.Collections.Generic;

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
				int hits = Data.ContainsKey("Hits") ? (int)Data["Hits"] : 1;

				if (hitTargets[targetHit] >= hits)
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

			DefaultHit(Attacker, Data, targetHit);
		}
	}

	public void Init(Vector3 position, Vector3 size, Character attacker)
	{
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
