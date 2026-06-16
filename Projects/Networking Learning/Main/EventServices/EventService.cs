using System;
using System.Collections.Generic;
using Godot;

public static class EventService
{
    private static Dictionary<string, Delegate> Events = [];
    
    public static void Fire<T>(T @event) where T : Event
    {
        if (Events.TryGetValue(@event.GetType().Name, out Delegate callback))
        {
            ((Action<T>)callback)?.Invoke(@event);
        }
    }

    public static void Subscribe<T>(params Action<T>[] callbacks) where T : Event
    {
        foreach (Action<T> callback in callbacks)
        {
            if (Events.ContainsKey(typeof(T).Name))
            {
                if (Events[typeof(T).Name] != null)
                {
                    Events[typeof(T).Name] = Delegate.Combine(callback, Events[typeof(T).Name]);
                }
            }
            else
            {
                Events[typeof(T).Name] = callback;
            }
        }
    }

    public static void Unsubscribe<T>(params Action<T>[] callbacks) where T : Event
    {
        foreach (Action<T> callback in callbacks)
        {
            if (Events.ContainsKey(typeof(T).Name))
            {
                Events[typeof(T).Name] = Delegate.Remove(Events[typeof(T).Name], callback);
            }
        }
    }
}
