using Godot;
using System;

public partial class AnimationsComponent : Component
{
    private AnimationPlayer animationPlayer;
    private IAnimatible anim;
    //? Priority Guide, 1 high , 2 medium , 3 low
    protected override void OnInit()
    {
        anim = Owner as IAnimatible;
        animationPlayer = Owner.GetNodeOrNull<AnimationPlayer>("AnimationPlayer");

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
    public void PlayAnim(string animName, int priority, float blendTime = 0.15f)
    {
        if (anim.CurrentAnim != animName && GetAnim(animName) != null)
        {
            if (priority <= anim.CurrentAnimPriority)
            {
                anim.CurrentAnimPriority = priority;
                anim.CurrentAnim = animName;
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
        anim.CurrentAnim = "";
        anim.CurrentAnimPriority = 3;
    }
}
