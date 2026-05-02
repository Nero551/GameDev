using Godot;
using System;

public partial class Character
{
	public void M1()
	{
		// ActiveHand = MainHand;
		BasicAttack();
	}
	public void M2()
	{
		// ActiveHand = OffHand;
		BasicAttack();
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

			if ((PULib.CurrentSTime() - LastSwingTime) >= (double)ActiveHand.itemData["ComboResetTime"])
			{
				SwingNumber = 0;
			}

			SwingNumber++;
			LastSwingTime = PULib.CurrentSTime();

			if (SwingNumber > (int)ActiveHand.itemData["Swings"])
			{
				LastComboTime = PULib.CurrentSTime();
				SwingNumber = 0;
			}

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
			PackedScene scene = GD.Load<PackedScene>("res://Main/Workspace/Hitbox.tscn");
			Hitbox hitbox = scene.Instantiate<Hitbox>();

			hitbox.Name = hitboxName;

			Godot.Collections.Dictionary hitboxData = (Godot.Collections.Dictionary)ActiveHand.itemData["Hitbox"];
			Vector3 hitboxSize = new Vector3((float)hitboxData["X"], (float)hitboxData["Y"], (float)hitboxData["Z"]);

			hitbox.Init(Rig.GetNode<Marker3D>("HitboxLocation").GlobalPosition, hitboxSize, this);
			PULib.ScheduleRemoval(hitbox, 0.2f);
		}
	}
}
