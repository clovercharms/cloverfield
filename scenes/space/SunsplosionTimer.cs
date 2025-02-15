using Godot;
using System;

public partial class SunsplosionTimer : Timer
{
    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        WorldEvents.Instance.WorldEventStarted += OnWorldEventStart;
        WorldEvents.Instance.WorldEventEnded += OnWorldEventEnd;
    }

    public void OnWorldEventStart(string eventName)
    {
        Paused = true;
    }
    public void OnWorldEventEnd(string eventName)
    {
        if (IsStopped())
        {
            return;
        }

        Paused = false;
        if (eventName == "Anglerfish" && TimeLeft < 30.0f)
        {
            Start(30.0f);
        }
    }
}

