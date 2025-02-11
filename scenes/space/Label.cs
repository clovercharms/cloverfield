using Godot;
using System;
using System.Linq;

namespace CloverField.Space;

public partial class Label : Node3D
{
    public Camera3D Camera { get; set; }

    public override void _Ready()
    {
        GetChildren().Cast<GeometryInstance3D>().ToList()
            .ForEach(child => child.Transparency = 1.0f);
    }

    public void OnCharmSelected(LuckyCharm charm)
    {
        var tween = GetTree().CreateTween().SetParallel(true);

        tween.TweenProperty(this, "position:y", 1.75, 0.25)
            .SetEase(Tween.EaseType.InOut)
            .SetTrans(Tween.TransitionType.Quad);

        GetChildren().ToList()
            .ForEach(
                child => tween.TweenProperty(child, "transparency", 0.0, 0.25)
                    .SetEase(Tween.EaseType.InOut)
                    .SetTrans(Tween.TransitionType.Quad)
            );
    }

    public void OnCharmUnsnapping()
    {
        var tween = GetTree().CreateTween().SetParallel(true);

        tween.TweenProperty(this, "position:y", 1.5, 0.25)
            .SetEase(Tween.EaseType.InOut)
            .SetTrans(Tween.TransitionType.Quad);

        GetChildren().ToList()
            .ForEach(
                child => tween.TweenProperty(child, "transparency", 1.0, 0.25)
                    .SetEase(Tween.EaseType.InOut)
                    .SetTrans(Tween.TransitionType.Quad)
            );
    }
}
