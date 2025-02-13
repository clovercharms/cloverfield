using Godot;
using System;
using System.Reflection.Metadata;

public partial class UboaScare : Control
{

	private RandomNumberGenerator rng = new();

	private bool state = true;
	private int buttonPresses = 0;
	private int activationCounter;
	[Export] private WorldEnvironment Env { get; set; }
	[Export] private DirectionalLight3D Sun { get; set; }
	[Export] private Button LightSwitch { get; set; }
	[Export] private Texture2D BtnOff { get; set; }
	[Export] private Texture2D BtnOn { get; set; }
	[Export] private TextureRect Uboa { get; set; }
	[Export] private AudioStreamPlayer3D BGM { get; set; }
	[Export] private AudioStreamPlayer SoundOn { get; set; }
	[Export] private AudioStreamPlayer SoundOff { get; set; }
	[Export] private AudioStreamPlayer SoundUboa { get; set; }
	// Called when the node enters the scene tree for the first time.

	private Tween tween;
	public override void _Ready()
	{
		activationCounter = (int) rng.RandfRange(5.0f, 10.0f)*2+1;
		WorldEvents.Instance.WorldEventStarted += OnWorldEventStart;

    }

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

	public void OnWorldEventStart(string eventName)
	{
		if (state == true) return;
		if (eventName == "Uboa") return;

		if(eventName == "Anglerfish")
		{
			// haha, the catgirl turned the lights on!
            SoundOn.Play();
        }

        state = true;
        buttonPresses = 0;
        LightSwitch.Icon = BtnOn;
        Env.Environment.AmbientLightEnergy = 0.1f;
        Sun.Visible = true;
    }

	public async void OnButtonPressed(){
		if (WorldEvents.Instance.IsOngoingEvent())
		{
			return;
		}

		buttonPresses++;

		state = !state;

		if (state){
			LightSwitch.Icon = BtnOn;
			SoundOn.Play();
			Env.Environment.AmbientLightEnergy = 0.1f;
			Sun.Visible = true;
		} else {
			LightSwitch.Icon = BtnOff;
			SoundOff.Play();
			Env.Environment.AmbientLightEnergy = 0.0f;
			Sun.Visible = false;
		}

		if (buttonPresses % activationCounter == 0){
			WorldEvents.Instance.StartEvent("Uboa");
            tween = GetTree().CreateTween();

			// begin uboa scare
			LightSwitch.Visible = false;
			Uboa.Visible = true;
			BGM.Stop();
			SoundUboa.Play();

			// tween scale
			tween.TweenProperty(Uboa, "custom_minimum_size", new Vector2(1000, 1000), 10d);
			await tween.ToSignal(tween, Tween.SignalName.Finished);

            // reset values
            WorldEvents.Instance.ClearCurrentEvent();
            Uboa.Visible = false;
			Uboa.CustomMinimumSize = new Vector2(200, 200);
			LightSwitch.Visible = true;
			BGM.Play();
			tween.Dispose();
			tween = null;
			OnButtonPressed();
            buttonPresses = 0;
        }
		

	}
}
