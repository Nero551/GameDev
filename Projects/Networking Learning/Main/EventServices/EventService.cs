using System;
using System.Collections.Generic;
using Godot;

public partial class EventService
{
    public static event Action ClientConnected;
    public enum Event
    {
        ClientConnected
    }
    public static Dictionary<Event, Action> EventsLookup = new()
    {
        {Event.ClientConnected, ClientConnected},
    };
    //TODO- need to make EventService since i realized i am starting to need C# events to replace signals.
    /*
        to make this eventservice i need to learn delegates and events. atleast that what i know i need to learn.
    */

    public static void Fire(Event @event, params object[] args)
    {
        if (EventsLookup.ContainsKey(@event))
        {
            EventsLookup[@event].Invoke();
        }
    }

    public static void Subscribe(Event @event, Action callback)
    {
        if (EventsLookup.ContainsKey(@event))
        {
            EventsLookup[@event] += callback;
        }
    }
    public static void Unsubscribe(Event @event, Action callback)
    {
        if (EventsLookup.ContainsKey(@event))
        {
            EventsLookup[@event] -= callback;
        }
    }
}
