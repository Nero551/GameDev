using System;
using System.Collections.Generic;
using Godot;

public static class EventService
{
    private static Dictionary<Type, Delegate> Events = [];

    public static void Fire<T>(T @event) where T : Event
    {
        if (Events.TryGetValue(@event.GetType(), out Delegate callback))
        {
            ((Action<T>)callback)?.Invoke(@event);
        }
    }

    public static void Subscribe<T>(params Action<T>[] callbacks) where T : Event
    {
        foreach (Action<T> callback in callbacks)
        {
            if (Events.ContainsKey(typeof(T)))
            {
                Events[typeof(T)] = Delegate.Combine(callback, Events[typeof(T)]);
            }
            else
            {
                Events[typeof(T)] = callback;
            }
        }
    }

    public static void Unsubscribe<T>(params Action<T>[] callbacks) where T : Event
    {
        foreach (Action<T> callback in callbacks)
        {
            if (Events.ContainsKey(typeof(T)))
            {
                Events[typeof(T)] = Delegate.Remove(Events[typeof(T)], callback);
            }
        }
    }
}
