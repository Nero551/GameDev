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
			if ((PULib.CurrentSTime() - LastComboTime) < (double)ActiveHand.itemData["ComboCooldown"])
			{
				return;
			}
			if (SwingNumber == (int)ActiveHand.itemData["Swings"] || (PULib.CurrentSTime() - LastSwingTime) >= 5)
			{
				LastComboTime = PULib.CurrentSTime();
				SwingNumber = 0;
			}
			SwingNumber++;
			LastSwingTime = PULib.CurrentSTime();

			string itemName = (string)ActiveHand.itemData["Name"];
			Animation swingAnim = GetAnim(itemName + "/" + "L" + SwingNumber);
			if (swingAnim == null)
			{
				return;
			}

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

			hitbox.Init(GlobalPosition - GlobalTransform.Basis.Z * 3f + Vector3.Up * 0.5f, new Vector3(0.75f, 1f, 0.75f), this);
			World.Hitboxes.AddChild(hitbox);
			PULib.ScheduleRemoval(hitbox, 0.2f);
		}
	}

	public void Block()
	{

	}
}
