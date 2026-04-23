using Godot;
using System;

public partial class Character
{
	public bool IsMoving()
	{
		Vector3 horizontal = new Vector3(Velocity.X, 0, Velocity.Z);
		return horizontal.LengthSquared() > 0.01f;
	}
}
