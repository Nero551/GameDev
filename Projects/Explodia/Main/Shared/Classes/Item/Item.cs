using Godot;
using System;

public partial class Item : Node3D
{
	public Godot.Collections.Dictionary itemData;
	public AnimationLibrary animationLibrary;
	[Export] public Character Master;

	public virtual void InitClass()
	{

	}
	public void Init(Character master)
	{
		Master = master;
		Master.ActiveHand = this;
		InitClass();
	}
}
