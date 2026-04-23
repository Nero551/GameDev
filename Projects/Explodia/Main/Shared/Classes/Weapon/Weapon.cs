using Godot;
using System;

public partial class Weapon : Item
{
	public override void InitClass()
	{
		itemData = PULib.JSONToCSharp("Main/Shared/Data/ItemData/WeaponData");
		itemData = (Godot.Collections.Dictionary)itemData[this.Name];
		animationLibrary =
		 Master.LoadAnimLibrary("Main/Shared/Assets/Items/Weapons/" + itemData["Type"] + "/" + itemData["Name"] + "/Animations");
		Master.AddAnimLibrary((string)itemData["Name"], animationLibrary);
	}
}
