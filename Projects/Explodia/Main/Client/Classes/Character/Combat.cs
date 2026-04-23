using Godot;
using System;

public partial class Character
{
	public void BasicAttack()
	{
		if (Input.IsActionPressed("Basic Attack") && CanAttack())
		{
			if (ActiveHand == null || ActiveHand is not Item)
			{
				return;
			}

			//TODO Learn Animation Tree
			//TODO ADD animations and marker event and link everything down to the marker event
			AddState("Attacking", 0.2);			
			string hitboxName = ActiveHand.itemData["Name"] + "Basic Attack Hitbox";
			if (World.Hitboxes.GetNodeOrNull<Hitbox>(hitboxName) == null)
			{
				var scene = GD.Load<PackedScene>("res://Main/Workspace/hitbox.tscn");
				Hitbox hitbox = scene.Instantiate<Hitbox>();

				hitbox.Name = hitboxName;
				hitbox.Position = GlobalPosition;

				hitbox.Init(new Vector3(2, 3f, 2), this);

				World.Hitboxes.AddChild(hitbox);

				GetTree().CreateTimer(0.2).Timeout += () =>
				{
					if (GodotObject.IsInstanceValid(hitbox))
						hitbox.QueueFree();
				};
			}
		}
	}

	public void Block()
	{

	}
}
