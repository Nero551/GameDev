using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

/// <summary>
/// Global event bus used for communication between systems.
/// </summary>
/// <remarks>
/// Events are identified by their type.
/// Subscribers receive the full event object rather than raw data.
/// </remarks>
/// 
public static class EventService
{
    private static readonly Dictionary<Type, Delegate> Events = [];

    public static void Fire<T>(T evnt) where T : Event
    {
        if (Events.TryGetValue(typeof(T), out Delegate callback))
        {
            ((Action<T>)callback)?.Invoke(evnt);
        }
    }

    public static void Subscribe<T>(params Action<T>[] callbacks) where T : Event
    {
        Type evnt = typeof(T);

        foreach (Action<T> callback in callbacks)
        {
            if (Events.ContainsKey(evnt))
            {
                if (Events[evnt].GetInvocationList().Contains(callback))
                {
                    continue;
                }

                Events[evnt] = Delegate.Combine(callback, Events[evnt]);
            }
            else
            {
                Events[evnt] = callback;
            }
        }
    }

    public static void Unsubscribe<T>(params Action<T>[] callbacks) where T : Event
    {
        Type evnt = typeof(T);

        foreach (Action<T> callback in callbacks)
        {
            if (Events.ContainsKey(evnt))
            {
                Events[evnt] = Delegate.Remove(Events[evnt], callback);
            }
        }
    }
}