using Godot;
using System;

public partial class Item : Node3D
{
	public Godot.Collections.Dictionary itemData;
	[Export] public Character Master;
	public void Init(Character master)
	{
		Master = master;
		Master.ActiveHand = this;
	}
}
