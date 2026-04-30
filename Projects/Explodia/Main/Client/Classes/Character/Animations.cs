using Godot;
using System;
using System.Security.Cryptography.X509Certificates;


public partial class Character
{
	private AnimationPlayer animationPlayer;
	//TODO make an animation priority system
	//? Priority Guide, 1 high , 2 medium , 3 low
	public void InitAnim()
	{
		animationPlayer = GetNodeOrNull<AnimationPlayer>("AnimationPlayer");

		if (animationPlayer == null)
		{
			GD.PushError("AnimationPlayer not found!");
		}
	}

	public AnimationLibrary LoadAnimLibrary(string filepath)

	{
		return GD.Load<AnimationLibrary>("res://" + filepath + ".tres");
	}

	public void AddAnimLibrary(string libraryName, AnimationLibrary library)
	{
		if (GetAnimLibrary(libraryName) == null)
		{
			animationPlayer.AddAnimationLibrary(libraryName, library);
		}
	}
	public void PlayAnim(string animName, int priority, float blendTime = 0.2f)
	{
		if (CurrentAnim != animName && GetAnim(animName) != null)
		{
			if (priority <= CurrentAnimPriority)
			{
				CurrentAnimPriority = priority;
				CurrentAnim = animName;
				animationPlayer.Play(animName, blendTime);
			}
		}
	}

	public AnimationLibrary GetAnimLibrary(string libraryName)
	{
		if (animationPlayer.HasAnimationLibrary(libraryName))
		{
			return animationPlayer.GetAnimationLibrary(libraryName);
		}
		return null;
	}

	public Animation GetAnim(string animName)
	{
		if (animationPlayer.HasAnimation(animName))
		{
			return animationPlayer.GetAnimation(animName);
		}
		GD.PushWarning("Animation: " + animName + " Doesn't Exist.");
		return null;
	}

	private void OnAnimFinished(string animName)
	{
		CurrentAnim = "";
		CurrentAnimPriority = 3;
	}
}
