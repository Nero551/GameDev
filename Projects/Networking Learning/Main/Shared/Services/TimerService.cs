using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Godot;

public partial class TimerService
{
    private static readonly Dictionary<Timer, Action> Timers = [];

    public static Timer CreateTimer(float durationInSeconds, bool repeat, Action callback)
    {
        Timer timer = new() { Duration = durationInSeconds, Remaining = durationInSeconds, Repeat = repeat };
        Timers.Add(timer, callback);

        return timer;
    }

    public static void Process(double delta)
    {
        foreach (var pair in Timers)
        {
            Timer timer = pair.Key;
            Action callback = pair.Value;
            timer.Remaining -= (float)delta;

            if (timer.Remaining <= 0)
            {
                callback.Invoke();
                if (timer.Repeat)
                {
                    timer.Remaining = timer.Duration;
                }
                else
                {
                    Timers.Remove(timer);
                }
            }
        }
    }

    public static void Connect(Timer timer, Action callback)
    {
        if (Timers.ContainsKey(timer))
        {
            if (Timers.TryGetValue(timer, out var existing))
            {
                Timers[timer] += callback;
            }
            else
            {
                Timers[timer] = callback;
            }
        }
    }

    public static void Disconnect(Timer timer, Action callback)
    {
        if (Timers.ContainsKey(timer))
        {
            if (Timers.TryGetValue(timer, out var existing))
            {
                Timers[timer] -= callback;
            }
        }
    }

    public static void Destroy(Timer timer)
    {
        if (Timers.ContainsKey(timer))
        {
            Timers.Remove(timer);
        }
    }
}
