using Godot;
using System;

public partial class Character
{
	public void BasicAttack()
	{
		//TODO Complete Basic Attack and do block and hitboxes and hitTypes
		//TODO Hitbox class that deals with collision with enemy , if collision then does hittype and dmg and stuff
		if (Input.IsActionPressed("Basic Attack") && CanAttack())
		{
			AddState("Attacking", 0.2);

			if (World.Hitboxes.GetNodeOrNull<Hitbox>("Basic Attack Hitbox") == null)
			{
				var scene = GD.Load<PackedScene>("res://Main/Workspace/hitbox.tscn");
				Hitbox hitbox = scene.Instantiate<Hitbox>();

				hitbox.Name = "Basic Attack Hitbox";
				hitbox.Position = GlobalPosition;

				hitbox.Init(new Vector3(2, 3f, 2), this, 10);

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
