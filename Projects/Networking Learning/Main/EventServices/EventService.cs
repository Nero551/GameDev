using System;
using System.Collections.Generic;
using Godot;

public partial class EventService
{
    public enum Event
    {
        ClientConnected
    }
    public static Dictionary<Event, Action> Events = new() { };
    //TODO- need to make EventService since i realized i am starting to need C# events to replace signals.
    /*
        to make this eventservice i need to learn delegates and events. atleast that what i know i need to learn.
    */

    public static void Fire(Event @event)
    {
        if (Events.TryGetValue(@event, out Action action))
            action?.Invoke();
    }

    public static void Subscribe(Event @event, Action callback)
    {
        if (Events.ContainsKey(@event))
        {
            Events[@event] += callback;
        }
        else
        {
            Events[@event] = callback;
        }
    }
    public static void Unsubscribe(Event @event, Action callback)
    {
        if (Events.ContainsKey(@event))
        {
            Events[@event] -= callback;
        }
    }
}
