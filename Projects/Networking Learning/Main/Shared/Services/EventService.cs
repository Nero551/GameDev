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
    /// <summary>
    /// Maps event types to their subscribed callbacks.
    /// </summary>
    /// 
    private static readonly Dictionary<Type, Delegate> Events = [];

    /// <summary>
    /// Fires an event and invokes all subscribed callbacks.
    /// </summary>
    /// <typeparam name="T">The event type.</typeparam>
    /// <param name="evnt">The event instance to dispatch.</param>
    /// 
    public static void Fire<T>(T evnt) where T : Event
    {
        if (Events.TryGetValue(typeof(T), out Delegate callback))
        {
            ((Action<T>)callback)?.Invoke(evnt);
        }
    }

    /// <summary>
    /// Subscribes one or more callbacks to an event type.
    /// </summary>
    /// <typeparam name="T">The event type.</typeparam>
    /// <param name="callbacks">Methods to invoke when the event is fired.</param>
    /// 
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

    /// <summary>
    /// Unsubscribes one or more callbacks from an event type.
    /// </summary>
    /// <typeparam name="T">The event type.</typeparam>
    /// <param name="callbacks">Methods to remove from the event.</param>
    /// 
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