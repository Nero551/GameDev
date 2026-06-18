using System;
using System.Collections.Generic;
using System.Linq;

public static class EventService
{
    /*
    *   How To Use:
    *       1- Create a class inheriting Event.
    *       2- Fire using Fire method
    *       3- other methods can subscribe to the event using subscribe
    *       4- the subscriber recieves the event object that u specified.
    
    ?   Notes:  the subscriber DOES NOT recieve raw data. itt recieves the event object containing the data.
    */

    private static Dictionary<Type, Delegate> Events = [];

    public static void Fire<T>(T evnt) where T : Event
    {

        //Checks if an action is connected to the event
        if (Events.TryGetValue(typeof(T), out Delegate callback))
        {
            ((Action<T>)callback)?.Invoke(evnt);
        }
    }

    public static void Subscribe<T>(params Action<T>[] callbacks) where T : Event
    {
        Type evnt = typeof(T);
        //The params and loop allow for multiple methods to subscribe in 1 line
        foreach (Action<T> callback in callbacks)
        {
            if (Events.ContainsKey(evnt))
            {
                //Checks if the action is already subscribed
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
        //The params and loop allow for multiple methods to subscribe in 1 line
        foreach (Action<T> callback in callbacks)
        {
            if (Events.ContainsKey(evnt))
            {
                Events[evnt] = Delegate.Remove(Events[evnt], callback);
            }
        }
    }
}
