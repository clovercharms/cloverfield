using Godot;
using System;
using System.Linq;

namespace CloverField.Space;

public partial class CharmSummoner : Node3D
{
	[Signal] public delegate void CatgirlFoundEventHandler();

	[Export] private Godot.Label Counter { get; set; }
	[Export] private int Amount  { get; set; } = 75 + 1; // 1st gets skipped because of headerline in csv
	[Export] private int PositionRange { get; set; } = 20;
	[Export] private float MinDistance { get; set; } = 3.0f;
	//[Export] private Godot.Collections.Array<Texture2D> Avatars { get; set; }
	[Export] private string ResponsesPath { get; set; }
	[Export] private Godot.Collections.Array<Texture2D> BodiesBase { get; set; }
	[Export] private Godot.Collections.Array<Texture2D> BodiesHeart { get; set; } // indices must match base
	[Export] private Texture2D CatgirlTexture { get; set; }

	private float HalfRange => PositionRange / 2;
	private Vector3[] GeneratedPosition { get; set; } = [];
	private LuckyCharm[] Instances { get; set; } = [];
	private bool SelectionActive { get; set; } = false;

	private int MessagesRead { get; set; } = 0;
	private int ResponsesCount { get; set; } = 0;

	public void ToggleSelection(LuckyCharm charm, bool disabled)
	{
		foreach (var child in GetChildren())
		{
			if (child is not LuckyCharm instance) continue;
			if (instance == charm) continue;
			instance.SelectionDisabled = disabled;
		}
	}

	public void UpdateCounter(LuckyCharm charm)
	{
		if (charm.HasBeenSelected) return;
		MessagesRead += 1;
		Counter.Text = $"Messages Read: {MessagesRead}/{ResponsesCount}";
	}

	public void ForwardCatgirlFound()
	{
		EmitSignal(SignalName.CatgirlFound);
	}

	public override void _Ready()
	{
		if(BodiesBase.Count != BodiesHeart.Count)
		{
			GD.PrintErr("Base body and heart eye variant counts do not match up!");
		}

		GodotObject fileResource = ResourceLoader.Load(ResponsesPath);
		var responsesArray = (Godot.Collections.Array)fileResource.Get("records");
		ResponsesCount = responsesArray.Count -1;

		Godot.Collections.Array<int> indexDeck = [];
		for (int i = 0; i < BodiesBase.Count; ++i) {
			indexDeck.Add(i);
		}

		string basePathAvatars = "res://..//..//assets//textures//Valentines2025//Avatars//";		
		Godot.Collections.Dictionary Avatars = new Godot.Collections.Dictionary {
			{ "Alca", ResourceLoader.Load(basePathAvatars + "Alca.png") },
			{ "ArchiveAnon", ResourceLoader.Load(basePathAvatars + "ArchiveAnon.png") },
			{ "Awysu", ResourceLoader.Load(basePathAvatars + "Awysu.png") },
			{ "Battery", ResourceLoader.Load(basePathAvatars + "Battery.png") },
			{ "Bingo The Flamingo", ResourceLoader.Load(basePathAvatars + "Bingo The Flamingo.png") },
			{ "boyong", ResourceLoader.Load(basePathAvatars + "boyong.png") },
			{ "Cturne", ResourceLoader.Load(basePathAvatars + "Cturne.png") },
			{ "Delicious Sandwich", ResourceLoader.Load(basePathAvatars + "Delicious Sandwich.png") },
			{ "Doko", ResourceLoader.Load(basePathAvatars + "Doko.png") },
			{ "DWraith23", ResourceLoader.Load(basePathAvatars + "DWraith23.png") },
			{ "Endor", ResourceLoader.Load(basePathAvatars + "Endor.png") },
			{ "Firebreath", ResourceLoader.Load(basePathAvatars + "Firebreath.png") },
			{ "Floran", ResourceLoader.Load(basePathAvatars + "Floran.png") },
			{ "GerardoS23", ResourceLoader.Load(basePathAvatars + "GerardoS23.png") },
			{ "Gotz", ResourceLoader.Load(basePathAvatars + "Gotz.png") },
			{ "Herbie_Cucumber", ResourceLoader.Load(basePathAvatars + "Herbie_Cucumber.png") },
			{ "iSneeze", ResourceLoader.Load(basePathAvatars + "iSneeze.png") },
			{ "Joseku", ResourceLoader.Load(basePathAvatars + "Joseku.png") },
			{ "Konsulus", ResourceLoader.Load(basePathAvatars + "Konsulus.png") },
			{ "Koudelka", ResourceLoader.Load(basePathAvatars + "Koudelka.png") },
			{ "kuriimu", ResourceLoader.Load(basePathAvatars + "kuriimu.png") },
			{ "Maedara", ResourceLoader.Load(basePathAvatars + "Maedara.png") },
			{ "Matze", ResourceLoader.Load(basePathAvatars + "Matze.png") },
			{ "Messed Up Brainspike", ResourceLoader.Load(basePathAvatars + "Messed Up Brainspike.png") },
			{ "MiiMoo", ResourceLoader.Load(basePathAvatars + "MiiMoo.png") },
			{ "Necrozma", ResourceLoader.Load(basePathAvatars + "Necrozma.png") },
			{ "Neon", ResourceLoader.Load(basePathAvatars + "Neon.png") },
			{ "Nilok", ResourceLoader.Load(basePathAvatars + "Nilok.png") },
			{ "Nova Dysnomia", ResourceLoader.Load(basePathAvatars + "Nova Dysnomia.png") },
			{ "Rellikai", ResourceLoader.Load(basePathAvatars + "Rellikai.png") },
			{ "Rhymeruru", ResourceLoader.Load(basePathAvatars + "Rhymeruru.png") },
			{ "Robotic658", ResourceLoader.Load(basePathAvatars + "Robotic658.png") },
			{ "samrye", ResourceLoader.Load(basePathAvatars + "samrye.png") },
			{ "SleepingSlime", ResourceLoader.Load(basePathAvatars + "SleepingSlime.png") },
			{ "UnamisCat", ResourceLoader.Load(basePathAvatars + "UnamisCat.png") },
			{ "WCTB", ResourceLoader.Load(basePathAvatars + "WCTB.png") },
			{ "Xiazee", ResourceLoader.Load(basePathAvatars + "Xiazee.png") },
			{ "Yann", ResourceLoader.Load(basePathAvatars + "Yann.png") }
		};

		string basePathDrawings = "res://..//..//assets//textures//Valentines2025//Drawings//";		
		Godot.Collections.Dictionary Drawings = new Godot.Collections.Dictionary {
			{ "Alca", ResourceLoader.Load(basePathDrawings + "Alca.png") },
			{ "ArchiveAnon", ResourceLoader.Load(basePathDrawings + "ArchiveAnon.png") },
			{ "Awysu", ResourceLoader.Load(basePathDrawings + "Awysu.png") },
			{ "Battery", ResourceLoader.Load(basePathDrawings + "Battery.png") },
			{ "Bingo The Flamingo", ResourceLoader.Load(basePathDrawings + "Bingo The Flamingo.png") },
			{ "Cturne", ResourceLoader.Load(basePathDrawings + "Cturne.png") },
			{ "CuriousRecluse", ResourceLoader.Load(basePathDrawings + "CuriousRecluse.png") },
			{ "Delicious Sandwich", ResourceLoader.Load(basePathDrawings + "Delicious Sandwich.png") },
			{ "Doko", ResourceLoader.Load(basePathDrawings + "Doko.png") },
			{ "DWraith23", ResourceLoader.Load(basePathDrawings + "DWraith23.png") },
			{ "Endor", ResourceLoader.Load(basePathDrawings + "Endor.png") },
			{ "Firebreath", ResourceLoader.Load(basePathDrawings + "Firebreath.png") },
			{ "Gotz", ResourceLoader.Load(basePathDrawings + "Gotz.png") },
			{ "Herbie_Cucumber", ResourceLoader.Load(basePathDrawings + "Herbie_Cucumber.png") },
			{ "iSneeze", ResourceLoader.Load(basePathDrawings + "iSneeze.png") },
			{ "Joseku", ResourceLoader.Load(basePathDrawings + "Joseku.png") },
			{ "Koudelka", ResourceLoader.Load(basePathDrawings + "Koudelka.png") },
			{ "kuriimu", ResourceLoader.Load(basePathDrawings + "kuriimu.png") },
			{ "Maedara", ResourceLoader.Load(basePathDrawings + "Maedara.png") },
			{ "Matze", ResourceLoader.Load(basePathDrawings + "Matze.png") },
			{ "Messed Up Brainspike", ResourceLoader.Load(basePathDrawings + "Messed Up Brainspike.png") },
			{ "MiiMoo", ResourceLoader.Load(basePathDrawings + "MiiMoo.png") },
			{ "mitty", ResourceLoader.Load(basePathDrawings + "mitty.png") },
			{ "Necrozma", ResourceLoader.Load(basePathDrawings + "Necrozma.png") },
			{ "Neon", ResourceLoader.Load(basePathDrawings + "Neon.png") },
			{ "Nilok", ResourceLoader.Load(basePathDrawings + "Nilok.png") },
			{ "Nova Dysnomia", ResourceLoader.Load(basePathDrawings + "Nova Dysnomia.png") },
			{ "Rhymeruru", ResourceLoader.Load(basePathDrawings + "Rhymeruru.png") },
			{ "Robotic658", ResourceLoader.Load(basePathDrawings + "Robotic658.png") },
			{ "Sahe", ResourceLoader.Load(basePathDrawings + "Sahe.png") },
			{ "samrye", ResourceLoader.Load(basePathDrawings + "samrye.png") },
			{ "Streamcrash", ResourceLoader.Load(basePathDrawings + "Streamcrash.png") },
			{ "UnamisCat", ResourceLoader.Load(basePathDrawings + "UnamisCat.png") },
			{ "Xiazee", ResourceLoader.Load(basePathDrawings + "Xiazee.png") }
		};

		// Skip the first line with the headers
		for (int i = 1; i < Amount; i++)
		{			
			var charm = LuckyCharm.GenerateInstance();
			charm.Camera = GetParent().FindChild("Mitty Cam") as MittyCam;
			charm.OrbitControls = GetParent().FindChild("OrbitControls") as Control;

			charm.Selected += selectedCharm => ToggleSelection(selectedCharm, true);
			charm.Selected += UpdateCounter;

			charm.Deselected += () => ToggleSelection(null, false);

			charm.CharmName = "Lucky Charm";

			if (i < responsesArray.Count)
			{
				if (responsesArray[i].AsStringArray()[2].Contains("Yes"))
				{
					charm.CharmName = responsesArray[i].AsStringArray()[1];
				}
				charm.CharmMessage = responsesArray[i].AsStringArray()[5];
				
				// Debug to check if everything is loaded
				GD.Print(charm.CharmName = responsesArray[i].AsStringArray()[1]);

							
				if(Avatars.ContainsKey(responsesArray[i].AsStringArray()[1]))
					charm.Avatar = (Texture2D)Avatars[responsesArray[i].AsStringArray()[1]];
				
				if(Drawings.ContainsKey(responsesArray[i].AsStringArray()[1]))
					charm.Drawing = (Texture2D)Drawings[responsesArray[i].AsStringArray()[1]];
			}
			else
			{
				charm.IsDummy = true;
			}

			if (i == Amount - 1) charm.IsCatgirl = true;

			// Shuffle all bodies, then draw one until none remain, shuffle and go again
			// aka Tetris piece selection logic
			int deckPos = i % BodiesBase.Count;
			if (deckPos == 0) {
				indexDeck.Shuffle();
			}
			
			charm.BodyTexture = BodiesBase[indexDeck[deckPos]];
			charm.BodyTextureHeart = BodiesHeart[indexDeck[deckPos]];

			if (charm.IsCatgirl) {
				charm.BodyTexture = CatgirlTexture;
				charm.BodyTextureHeart = CatgirlTexture;
				charm.CatgirlFound += () => ForwardCatgirlFound();
			}

			if (charm.IsDummy) charm.Avatar = charm.BodyTexture;

			charm.Position = MakeRandomPlanetPosition();
			var marker = new Marker3D();
			charm.Pivoter = marker;
			AddChild(marker);
			marker.AddChild(charm);

			GD.Print($"Charm added.  Dummy? {charm.IsDummy} | Charms: {GetChildCount()}");
		}
		Counter.Text = $"Messages Read: {MessagesRead}/{ResponsesCount}";
	}

	private Vector3 MakeRandomPlanetPosition()
	{
		var theta = GD.RandRange(0, Math.PI * 2);
		var phi = GD.RandRange(0, Math.PI); // I"M NOT GREEK!  THE FUCK DOES THIS MEAN? // Theta and phi are traditional variable names for angles in math equations.
		var radius = 25f;       // WHAT THE FUCK WAS THIS BULLSHIT?! // This was basically rolling the latitude and longitude and then adjusting the location for how big the planet is.

		var x = (float)(radius * Math.Sin(theta) * Math.Cos(phi));
		var y = (float)(radius * Math.Sin(theta) * Math.Sin(phi));
		var z = (float)(radius * Math.Cos(theta));

		return new Vector3(x, y, z);
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
