using Godot;
using System;

public partial class TheOrb : StaticBody3D
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

	public static void SummonTheOrb(Vector3 position, Node parent)
	{
		var orb = GD.Load<PackedScene>("res://wraiths dumb tests/the_orb.tscn").Instantiate<TheOrb>();
		parent.AddChild(orb);
		orb.GlobalPosition = position;
		GD.Print($"AN ORB HAS BEEN SUMMONED! at {position}");
	}
}
