using Godot;
using System;
using System.Collections.Generic;

public partial class EHitbox : Area3D
{
	/*
	TODO- add a spawn hitbox method here.
	TODO- infact how about a global spawn (insert entity) method that can be overridden by every entity
	*/
	public Entity Entity;

	private Dictionary<ECharacter, int> hitTargets = new();
	private Godot.Collections.Dictionary Data;

	public ECharacter Attacker;
	public CDefaultHit cDefaultHit;

	public void OnBodyEntered(Node3D body)
	{
		
		ECharacter targetHit = body.GetOwner<ECharacter>();

		if (targetHit != null && targetHit is ECharacter && targetHit != Attacker)
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
			cDefaultHit.DefaultHit(Attacker, targetHit, Data);

		}
	}

	public void Init(Vector3 position, Vector3 size, ECharacter attacker)
	{
		Entity = Entity.Create(this);

		SetHitboxSize(size);
		SetHitboxPosition(position);
		Attacker = attacker;
		Data = Attacker.ActiveHand.itemData;

		cDefaultHit = Entity.AddComponent<CDefaultHit>();

		World.Hitboxes.AddChild(this);
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
