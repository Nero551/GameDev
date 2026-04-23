using Godot;
using System;

public partial class Weapon : Item
{
	public override void _Ready()
	{
		itemData = PULib.JSONToCSharp("Main/Shared/Data/ItemData/WeaponData");
		GD.Print(itemData);
		itemData = (Godot.Collections.Dictionary)itemData[this.Name];
	}
}
