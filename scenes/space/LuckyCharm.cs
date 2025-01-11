using Godot;
using System;

public partial class LuckyCharm : CharacterBody3D
{
    [Export] private NavigationAgent3D Navigation { get; set; }
    [Export] private float WanderRange { get; set; } = 10f;
    [Export] private float Acceleration { get; set; } = 1f;

    private Vector3 Destination { get; set; }


    public const float Speed = 5.0f;
    public const float JumpVelocity = 4.5f;

    public override void _PhysicsProcess(double delta)
    {
        
        Vector3 velocity = Velocity;

        // Add the gravity.
        if (!IsOnFloor())
        {
            velocity += GetGravity() * (float)delta;
        }

        Wander();

        // var direction = ($NavigationAgent3D.get_next_path_position() - global_position).normalized()
        // velocity = velocity.lerp(direction * speed, accel * delta)

        var direction = (Navigation.GetNextPathPosition() - GlobalPosition).Normalized();
        Velocity = Velocity.Lerp(direction * Speed, (float)(Acceleration * delta));

        MoveAndSlide();
    }

    private void Wander()
    {
        if (Destination != Vector3.Zero && GlobalPosition.DistanceTo(Destination) > 0.5f) return;
        GD.Print("Fuck");
        if (NavigationServer3D.MapGetIterationId(NavigationServer3D.GetMaps()[0]) == 0) return;
        GD.Print("AAAAAA");
        GD.Print($"Destination: {Destination} | GlobalPosition: {GlobalPosition} | Distance: {GlobalPosition.DistanceTo(Destination)}");
        GD.Print($"|    Velocity: {Velocity}");

        var theta = GD.RandRange(0, Math.PI * 2);
        var phi = GD.RandRange(0, Math.PI); // I"M NOT GREEK!  THE FUCK DOES THIS MEAN?
        var radius = 50f;       // WHAT THE FUCK WAS THIS BULLSHIT?!

        var x = (float)(radius * Math.Sin(theta) * Math.Cos(phi));
        var y = (float)(radius * Math.Sin(theta) * Math.Sin(phi));
        var z = (float)(radius * Math.Cos(theta));

        Destination = new Vector3(x, y, z);
        
        GD.Print($"|    Destination: {Destination}");
        Destination = NavigationServer3D.MapGetClosestPoint(NavigationServer3D.GetMaps()[0], Destination);
        GD.Print($"|    Destination after MapGetClosestPoint: {Destination}");
        Navigation.TargetPosition = Destination;
    }
}


// func _wander():
//     if destination != Vector3.ZERO && global_position.distance_to(destination) > 0.5:
//         return
        
//     # Generate random walking position
//     destination = Vector3(
//         randf_range(-wander_range, wander_range),
//         0.5,
//         randf_range(-wander_range, wander_range)
//     )
//     destination = NavigationServer3D.map_get_closest_point(
//         NavigationServer3D.get_maps()[0],
//         destination
//     );
//     $NavigationAgent3D.target_position = destination
