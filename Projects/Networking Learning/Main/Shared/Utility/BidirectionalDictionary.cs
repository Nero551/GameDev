using System;
using System.Collections.Generic;
using Godot;

public class BidirectionalDictionary<T1, T2>
{
    private Dictionary<T1, T2> forward = [];
    private Dictionary<T2, T1> reverse = [];


    public void Add(T1 key, T2 value)
    {
        forward.Add(key, value);
        reverse.Add(value, key);
    }

    public T2 GetByKey(T1 key)
    {
        return forward[key];
    }

    public T1 GetByValue(T2 value)
    {
        return reverse[value];
    }

    public bool TryGetByKey(T1 key, out T2 value)
    {
        return forward.TryGetValue(key, out value);
    }

    public bool TryGetByValue(T2 value, out T1 key)
    {
        return reverse.TryGetValue(value, out key);
    }
}
