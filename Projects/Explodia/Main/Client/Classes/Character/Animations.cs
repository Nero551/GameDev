using Godot;
using System;

public partial class Character
{
	private AnimationPlayer animationPlayer;
	public void InitAnim()
	{
		animationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
	}
	public void PlayAnim(string animName,float blendTime = 0.2f)
	{
		if (animationPlayer.CurrentAnimation != animName && animationPlayer.GetAnimation(animName) != null)
		{
			animationPlayer.Play(animName,blendTime);
		}
	}

	public Animation GetAnim(string animName)
	{
		return animationPlayer.GetAnimation(animName);
	}
	
	
}
