using Godot;
using System;
using System.Threading.Tasks;

namespace CloverField.Space;

public partial class Space : Node3D
{
	[Export] private DirectionalLight3D TheSun { get; set; }
	[Export] private AudioStreamPlayer3D BGM { get; set; }
	[Export] private AudioStreamPlayer3D EndMusic { get; set; }
	[Export] private Timer SunsplosionTimer { get; set; }
	[ExportGroup("Heart Particles")]
	[Export] private GpuParticles2D[] HeartParticles { get; set; }
	[Export] private GpuParticles2D HeartParticlesTopLeft { get; set; }
	[Export] private GpuParticles2D HeartParticlesTopRight { get; set; }
	[Export] private GpuParticles2D HeartParticlesBottomLeft { get; set; }
	[Export] private GpuParticles2D HeartParticlesBottomRight { get; set; }

	private static Color StartingSunColor => Color.FromHtml("fde8d3");
	private static float StartingSunEnergy => 1.8f;

	public override async void _Ready()
	{
		await ToSignal(GetTree().CreateTimer(1), Timer.SignalName.Timeout);
		BGM.Play();
		var musicTween = GetTree().CreateTween();
		musicTween.TweenProperty(BGM, "volume_db", -10f, 10d);
	}
	
	private double AccumulatedTime { get; set; } = 0d;
    public override void _Process(double delta)
    {
        AccumulatedTime += delta;
		if (AccumulatedTime < 1d) return;
		AdjustHeartParticlePositions();
    }

	private void AdjustHeartParticlePositions()
	{
		var viewport = GetViewport();
		var rect = viewport.GetVisibleRect();
		var tl = rect.Position;
		var tr = new Vector2(rect.End.X, rect.Position.Y);
		var bl = new Vector2(rect.Position.X, rect.End.Y);
		var br = rect.End;

		HeartParticlesTopLeft.Position = new(tl.X + 100, tl.Y - 25);
		HeartParticlesTopRight.Position = new(tr.X - 100, tr.Y - 25);
		HeartParticlesBottomLeft.Position = new(bl.X + 100, bl.Y + 25);
		HeartParticlesBottomRight.Position = new(br.X - 100, br.Y + 25);
	}

    private async void SunExplosion()
	{
		SunsplosionTimer.Paused = true;
		GD.Print("Sun explosion!");
		WorldEvents.Instance.StartEvent("SunExplosion");
		SetHeartsEmitting(false);
        // End music
        GD.Print("Phase 1!");
		var volumeTween = GetTree().CreateTween().SetParallel(true);
		EndMusic.Play();
		volumeTween.TweenProperty(BGM, "volume_db", -60f, 20d);
		volumeTween.TweenProperty(EndMusic, "volume_db", -10f, 20d);
		await volumeTween.ToSignal(volumeTween, Tween.SignalName.Finished);
		BGM.Stop();

		

		GD.Print("Setting timer for 20 seconds.");
		var explodingTime = GetTree().CreateTimer(20f);
		await explodingTime.ToSignal(explodingTime, Timer.SignalName.Timeout);
		GD.Print("Timer finished!  Sun explosion go brrrrrr!");

		// Sun blue-ing
		GD.Print("Phase 2!");
		var sunTween = GetTree().CreateTween().SetParallel(true);
		var color = Color.FromHtml("a7fffa");
		sunTween.TweenProperty(TheSun, "light_color", color, 5d);
		sunTween.TweenProperty(TheSun, "light_energy", 3, 5d);
		await sunTween.ToSignal(sunTween, Tween.SignalName.Finished);

		// Sun shrinking
		GD.Print("Phase 3!");
		var shrinkTween = GetTree().CreateTween();
		shrinkTween.TweenProperty(TheSun, "light_energy", 0, 5d);
		await shrinkTween.ToSignal(shrinkTween, Tween.SignalName.Finished);

		// Sun explosion
		GD.Print("Phase 4!");
		var sizeTween = GetTree().CreateTween().SetParallel(true);
		sizeTween.TweenProperty(TheSun, "light_energy", 16f, 5d);
		sizeTween.TweenProperty(TheSun, "light_angular_distance", 89f, 15d);
		await sizeTween.ToSignal(sizeTween, Tween.SignalName.Finished);

		// Reversion
		var reversionTimer = GetTree().CreateTimer(10f);
		await reversionTimer.ToSignal(reversionTimer, Timer.SignalName.Timeout);
		BGM.Play();
		var reversionTween = GetTree().CreateTween().SetParallel(true);
		reversionTween.TweenProperty(TheSun, "light_color", StartingSunColor, 5d);
		reversionTween.TweenProperty(TheSun, "light_energy", StartingSunEnergy, 5d);
		reversionTween.TweenProperty(TheSun, "light_angular_distance", 0f, 5d);
		reversionTween.TweenProperty(BGM, "volume_db", -10f, 20d);
		reversionTween.TweenProperty(EndMusic, "volume_db", -80f, 20d);
		await reversionTween.ToSignal(reversionTween, Tween.SignalName.Finished);
		EndMusic.Stop();
		WorldEvents.Instance.ClearCurrentEvent();
		SetHeartsEmitting(true);
		SunsplosionTimer.Paused = false;
    }

	private void SetHeartsEmitting(bool emitting)
	{
		foreach (var particles in HeartParticles)
		{
			particles.Emitting = emitting;
		}
	}
	
}
