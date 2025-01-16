using Godot;
using System;

public partial class MickeyMouseRetro : Node3D
{
    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(double delta)
    {
        RotationDegrees = new(0f, RotationDegrees.Y + (float)delta * 100, 0f);
    }
}
