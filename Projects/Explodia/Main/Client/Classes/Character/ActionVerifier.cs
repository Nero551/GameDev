using Godot;
using System;

public partial class Character
{
	public bool CanAttack()
	{
		if (CheckState("Attacking","Blocking"))
		{
			return false;
		}
		return true;
	}
}
