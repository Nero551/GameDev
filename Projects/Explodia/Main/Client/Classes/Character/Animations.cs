using Godot;
using System;

public partial class Character
{
	private AnimationPlayer animationPlayer;
	public void InitAnim()
	{
		animationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
	}
	public void PlayAnim(string animName)
	{
		if (animationPlayer.CurrentAnimation != animName && animationPlayer.GetAnimation(animName) != null)
		{
			animationPlayer.Play(animName,0.2);
		}
	}
}
