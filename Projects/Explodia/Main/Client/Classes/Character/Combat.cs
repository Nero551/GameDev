using Godot;
using System;

public partial class Character
{
	public void BasicAttack()
	{
		if ( Input.IsActionPressed("Basic Attack"))
		{
			GD.Print("Attack");
			AddState("Attacking",0.2);
			

		}
	}

	public void Block()
	{
		
	}
}
