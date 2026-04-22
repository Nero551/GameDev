using Godot;
using Godot.NativeInterop;
using System;
using System.Collections.Generic;

public partial class Hitbox : Area3D
{

	private HashSet<Character> hitTargets = new();

	private Godot.Collections.Dictionary Data;
	public Character Attacker;
	public float Damage;
	public void OnBodyEntered(Node3D body)
	{
		var character = body.GetOwner<Character>();

		if (character != null && character is Character && character != Attacker)
		{
			if (hitTargets.Contains(character))
			{
				return;
			}
			hitTargets.Add(character);

			//Actual Hit Logic Here pls
			if (character.CheckState("Blocking"))
			{
				if (false)
				{
					//TODO Block break logic
				}
				else
				{
					//TODO blocked logic
				}
			}
			else
			{
				//TODO Default hit
			}
		}
	}

	public void Init(Vector3 size, Character attacker, float damage)
	{
		SetHitboxSize(size);
		Attacker = attacker;
		Damage = damage;
	}

	public void SetHitboxSize(Vector3 size)
	{
		var shape = (BoxShape3D)GetNode<CollisionShape3D>("CollisionShape3D").Shape;
		shape.Size = size;
	}
}
