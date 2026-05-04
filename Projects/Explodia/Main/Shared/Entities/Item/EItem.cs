using Godot;
using System;

public partial class EItem : Node3D
{
	public Godot.Collections.Dictionary itemData;
	public AnimationLibrary animationLibrary;
	[Export] public ECharacter Master;

	public virtual void InitClass()
	{

	}
	public void Init(ECharacter master)
	{
		Master = master;
		Master.ActiveHand = this;
		InitClass();
	}
}
