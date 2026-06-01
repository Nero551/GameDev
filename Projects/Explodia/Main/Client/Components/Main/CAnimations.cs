using System;
using Godot;

public partial class CAnimations : Component
{
    private AnimationPlayer animationPlayer;

    [Export] public int CurrentAnimPriority = 3;
    [Export] public string CurrentAnim = "";

    //? Priority Guide, 1 high , 2 medium , 3 low
    protected override void OnInit()
    {
        animationPlayer = ComponentHost.Owner.GetNodeOrNull<AnimationPlayer>("AnimationPlayer");

        if (animationPlayer == null)
        {
            GD.PushWarning("AnimationPlayer not found!");
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
    public void PlayAnim(string animName, int priority, float blendTime = 0.15f)
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

    public void OnAnimFinished(string animName)
    {
        CurrentAnim = "";
        CurrentAnimPriority = 3;
    }

}
