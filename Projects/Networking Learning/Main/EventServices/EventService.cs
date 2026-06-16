using System;
using System.Collections.Generic;
using Godot;

public class EventService
{
    public static Dictionary<string, Delegate> Events = [];
    //TODO- need to make EventService since i realized i am starting to need C# events to replace signals.
    /*
        to make this eventservice i need to learn delegates and events. atleast that what i know i need to learn.
    */

    public static void Fire<T>(T @event) where T : Event
    {
        if (Events.TryGetValue(@event.GetType().Name, out Delegate callback))
        {
            ((Action<T>)callback)?.Invoke(@event);
        }
    }

    public static void Subscribe<T>(Action<T> callback) where T : Event
    {
        if (Events.ContainsKey(typeof(T).Name))
        {
            if (Events[typeof(T).Name] != null)
            {
                Events[typeof(T).Name] = Delegate.Combine(callback, Events[typeof(T).Name]);
                return;
            }
        }
        Events[typeof(T).Name] = callback;
    }

    public static void Unsubscribe<T>(Action<T> callback) where T : Event
    {
        if (Events.ContainsValue(callback))
        {
            Events[typeof(T).Name] = Delegate.Remove(Events[typeof(T).Name], callback);
        }
    }
}
