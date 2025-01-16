using Godot;
using System;

public partial class CharmSummoner : Node3D
{
    [Export] private int Amount  { get; set; } = 100;
    [Export] private int PositionRange { get; set; } = 20;
    [Export] private float MinDistance { get; set; } = 3.0f;

    private float HalfRange => PositionRange / 2;
    private Vector3[] GeneratedPosition { get; set; } = [];
    private LuckyCharm[] Instances { get; set; } = [];
    private bool SelectionActive { get; set; } = false;

    private static Texture2D[] Avatars =>
    [

    ];

    private static Texture2D[] Bodies =>
    [

    ];

    public void ToggleSelection(LuckyCharm charm, bool disabled)
    {
        foreach (var child in GetChildren())
        {
            if (child is not LuckyCharm instance) continue;
            if (instance == charm) continue;
            instance.SelectionDisabled = disabled;
        }
    }

    public override void _Ready()
    {
        for (int i = 0; i < Amount; i++)
        {
            var charm = LuckyCharm.GenerateInstance();
            charm.Camera = GetParent().FindChild("Mitty Cam") as MittyCam;
            charm.OrbitControls = GetParent().FindChild("OrbitControls") as Control;

            charm.Selected += (LuckyCharm selectedCharm) => ToggleSelection(selectedCharm, true);

            charm.Deselected += () => ToggleSelection(null, false);

            // charm.Avatar = Avatars[GD.RandRange(0, Avatars.Length - 1)];
            // charm.BodyTexture = Bodies[GD.RandRange(0, Bodies.Length - 1)];

            var theta = GD.RandRange(0, Math.PI * 2);
            var phi = GD.RandRange(0, Math.PI); // I"M NOT GREEK!  THE FUCK DOES THIS MEAN?
            var radius = 25f;       // WHAT THE FUCK WAS THIS BULLSHIT?!

            var x = (float)(radius * Math.Sin(theta) * Math.Cos(phi));
            var y = (float)(radius * Math.Sin(theta) * Math.Sin(phi));
            var z = (float)(radius * Math.Cos(theta));

            var randomPosition = new Vector3(x, y, z);
            charm.Position = randomPosition;
            var marker = new Marker3D();
            charm.Pivoter = marker;
            AddChild(marker);
            marker.AddChild(charm);
        }
    }

    // func _ready():
    // for i in range(amount):
    //     @warning_ignore("confusable_local_usage", "shadowed_variable")
    //     var clover = clover.instantiate() as Node3D
    //     clover.camera = get_node("../Camera3D")
    //     clover.orbit_controls = get_node("../OrbitControls")
    //     # Disable selections on all clovers when one is selected
    //     clover.selected.connect(func(instance): _toggle_selections(instance, true))
    //     # Re-enable selections on deselect
    //     clover.deselected.connect(func(): _toggle_selections(null, false))
    //     # Choose random body/avatar
    //     clover.avatar = avatars[randi_range(0, avatars.size()-1)]
    //     clover.body = bodies[randi_range(0, bodies.size()-1)]

    //     # Keep generating random spawn positions until atleast min_distance from
    //     # other clovers in the field
    //     while true:
    //         var random_position = Vector3(
    //             randf_range(-half_range, half_range),
    //             0.5,
    //             randf_range(-half_range, half_range)
    //         )

    //         var distance_threshold_reached = false
    //         for generated_position in generated_positions:
    //             if generated_position.distance_to(random_position) < min_distance:
    //                 distance_threshold_reached = true
    //                 break

    //         if !distance_threshold_reached:
    //             clover.position = random_position
    //             generated_positions.append(random_position)
    //             break

    //     # Randomize orientation
    //     if randi_range(0, 1) == 0:
    //         clover.get_node("Body").rotation.y = PI

    //     add_child(clover)

}
