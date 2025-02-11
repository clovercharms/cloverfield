using Godot;
using System;

namespace CloverField.Space;

public partial class Space : Node3D
{
	public void _on_timer_sun_hue_change_timeout(){
		GD.Print("TIMEOUT: Sun hue change!");
	}

		public void _on_timer_end_music_start_timeout(){
		GD.Print("TIMEOUT: End music start!");
	}

		public void _on_timer_sun_explode_timeout(){
		GD.Print("TIMEOUT: Sun explode!");
	}
	
}
