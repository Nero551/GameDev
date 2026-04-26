using Godot;
using System;
using System.IO;


public partial class Character
{
	private AnimationPlayer animationPlayer;
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
		GD.Print(filepath);
		return GD.Load<AnimationLibrary>("res://" + filepath + ".tres");
	}

	public AnimationLibrary GetAnimLibrary(string libraryName)
	{
		if (animationPlayer.HasAnimationLibrary(libraryName))
		{
			return animationPlayer.GetAnimationLibrary(libraryName);
		}
		return null;
	}

	public Animation GetAnimFromLibrary(string libraryName, string animName)
	{
		return GetAnimLibrary(libraryName).GetAnimation(animName);
	}

	public void AddAnimLibrary(string libraryName, AnimationLibrary library)
	{
		if (GetAnimLibrary(libraryName) == null)
		{
			animationPlayer.AddAnimationLibrary(libraryName, library);
		}
	}

	public void PlayAnimFromLibrary(string libraryName, string animName)
	{
		animationPlayer.Play(libraryName + "/" + animName);
	}
	public void PlayAnim(string animName, float blendTime = 0.2f)
	{
		if (animationPlayer.CurrentAnimation != animName && animationPlayer.GetAnimation(animName) != null)
		{
			animationPlayer.Play(animName, blendTime);
		}
	}


	public Animation GetAnim(string animName)
	{
		return animationPlayer.GetAnimation(animName);
	}
}
