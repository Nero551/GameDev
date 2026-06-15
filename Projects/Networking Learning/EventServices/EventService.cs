using System;
using System.Collections.Generic;
using Godot;

public partial class EventService
{
    public static event EventHandler OnClientConnected;
    public enum Event
    {
        OnClientConnected
    }
    public static Dictionary<Event, EventHandler> EventsLookup = [];
    //TODO- need to make EventService since i realized i am starting to need C# events to replace signals.
    /*
        to make this eventservice i need to learn delegates and events. atleast that what i know i need to learn.
    */

    public static void Invoke(Event @event, object sender, EventArgs eventArgs)
    {
        
        OnClientConnected.Invoke(sender, eventArgs);
    }

    public static void Subscribe(Event @event) { }
    public static void Unsubscribe(Event @event) { }
    
}
