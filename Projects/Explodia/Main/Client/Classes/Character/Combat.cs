using Godot;
using System;
using System.Threading;
using System.Threading.Tasks;

public partial class Character
{

	//TODO These two functions will be the entry from client to server
	//TODO based on the item equipped they will choose one of the functions below them (basic attack, etc)
	public void M1()
	{

	}
	public void M2()
	{

	}

	public void BasicAttack()
	{
		if (CanAttack())
		{
			if (ActiveHand == null || ActiveHand is not Item || ActiveHand.animationLibrary == null)
			{
				return;
			}
			if (SwingNumber == (int)ActiveHand.itemData["Swings"])
			{
				GetTree().CreateTimer((double)ActiveHand.itemData["ComboCooldown"]);
				SwingNumber = 0;
			}
			SwingNumber++;

			string itemName = (string)ActiveHand.itemData["Name"];
			Animation swingAnim = GetAnim(itemName + "/" + "L" + SwingNumber);
			if (swingAnim == null)
			{
				return;
			}

			//Todo ADD animations and marker event and link everything down to the marker event
			AddState("Attacking", swingAnim.Length);
			PlayAnim(itemName + "/" + "L" + SwingNumber, 1);
		}
	}

	public void OnHitMarker()
	{
		string itemName = (string)ActiveHand.itemData["Name"];
		string hitboxName = itemName + "Basic Attack Hitbox";
		if (World.Hitboxes.GetNodeOrNull<Hitbox>(hitboxName) == null)
		{
			PackedScene scene = GD.Load<PackedScene>("res://Main/Workspace/hitbox.tscn");
			Hitbox hitbox = scene.Instantiate<Hitbox>();

			hitbox.Name = hitboxName;
			hitbox.Position = GlobalPosition;

			hitbox.Init(new Vector3(2, 3f, 2), this);

			World.Hitboxes.AddChild(hitbox);
		}
	}

	public void Block()
	{

	}
}
