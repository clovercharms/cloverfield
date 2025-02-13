using Godot;
using System;

public partial class WorldEvents : Node
{
    [Signal] public delegate void WorldEventStartedEventHandler(string startedEvent);
    [Signal] public delegate void WorldEventEndedEventHandler(string endedEvent);
    public static WorldEvents Instance { get; private set; }
    private string CurrentEvent { get; set; } = "";

    public override void _Ready()
    {
        Instance = this;
    }

    public string GetCurrentEvent()
    {
        return CurrentEvent;
    }

    public bool StartEvent(string newEvent)
    {
        GD.Print($"Starting event: {newEvent}");
        if (IsOngoingEvent()) return false;
        CurrentEvent = newEvent;
        EmitSignal(SignalName.WorldEventStarted, newEvent);
        return true;
    }

    public void ClearCurrentEvent()
    {
        string justEnding = CurrentEvent;
        CurrentEvent = "";

        if(justEnding != "")
        {
            EmitSignal(SignalName.WorldEventEnded, justEnding);
        }
    }

    public bool IsOngoingEvent()
    {
        return CurrentEvent != "";
    }
}
