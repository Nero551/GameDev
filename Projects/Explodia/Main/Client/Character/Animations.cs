using Godot;
using System;

public partial class Character
{
	// Called when the node enters the scene tree for the first time.
	public void PlayAnim(string animName)
	{
		var animationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
		if (animationPlayer.CurrentAnimation != animName && animationPlayer.GetAnimation(animName) != null)
		{
			animationPlayer.Play(animName);
		}
	}
}
