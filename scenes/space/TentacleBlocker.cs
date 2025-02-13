using CloverField.Space;
using Godot;
using System;

public partial class TentacleBlocker : Area3D
{
    private void OnCharmAreaEntered(Area3D area)
    {
        GD.Print("Area entered????");
        var parent = area.GetParent();
        if (parent == null || parent is not LuckyCharm charm) return;

        GD.Print($"{charm.CharmName} redirected.");
        charm.RedirectWander();
    }
}
