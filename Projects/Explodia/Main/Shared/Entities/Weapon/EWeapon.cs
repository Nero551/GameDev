using Godot;
using System;

public partial class EWeapon : EItem
{
	public override void InitClass()
	{
		itemData = PULib.JSONToCSharp("Main/Shared/Data/ItemData/WeaponData");
		itemData = (Godot.Collections.Dictionary)itemData[this.Name];
		animationLibrary =
		 Master.CAnimations.LoadAnimLibrary("Main/Shared/Assets/Items/Weapons/" + itemData["Type"] + "/" + itemData["Name"] + "/Animations");
		Master.CAnimations.AddAnimLibrary((string)itemData["Name"], animationLibrary);
	}
}
