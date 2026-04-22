using Godot;
using System;

public partial class Character
{
	public bool CanAttack()
	{
		if (CheckState("Attacking,Blocking"))
		{
			GD.Print("Nice");
			return false;
		}
		return true;
	}
}
