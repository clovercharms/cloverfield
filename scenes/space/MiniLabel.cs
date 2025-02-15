using Godot;
using System;
using System.Linq;

namespace CloverField.Space;

public partial class MiniLabel : Node3D
{
    [Export] public MeshInstance3D Avatar { get; set; }

    public void OnCharmHoverEntered()
    {
        var tween = GetTree().CreateTween();
        tween.TweenProperty(this, "position:y", 0.9, 0.25)
            .SetEase(Tween.EaseType.InOut)
            .SetTrans(Tween.TransitionType.Quad);
    }

    public void OnCharmHoverExited()
    {
        var tween = GetTree().CreateTween();
        tween.TweenProperty(this, "position:y", 0.8, 0.25)
            .SetEase(Tween.EaseType.InOut)
            .SetTrans(Tween.TransitionType.Quad);
    }

    public void OnCharmSelected(LuckyCharm charm)
    {
        var tween = GetTree().CreateTween().SetParallel(true);
        GetChildren().ToList()
            .ForEach(
                child => tween.TweenProperty(child, "transparency", 1.0, 0.25)
                    .SetEase(Tween.EaseType.InOut)
                    .SetTrans(Tween.TransitionType.Quad)
            );
    }

    public void OnCharmDeselected()
    {
        var tween = GetTree().CreateTween().SetParallel(true);
        GetChildren().ToList()
            .ForEach(
                child => tween.TweenProperty(child, "transparency", 0.0, 0.25)
                    .SetEase(Tween.EaseType.InOut)
                    .SetTrans(Tween.TransitionType.Quad)
            );
    }
}
