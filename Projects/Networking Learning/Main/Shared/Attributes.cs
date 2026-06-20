using System;
using Godot;

public enum ReplicationMode
{
    Reliable,
    Unreliable
}
[AttributeUsage(AttributeTargets.Field)]
public class Replicated(ReplicationMode mode) : Attribute
{
    public ReplicationMode Mode => mode;
}