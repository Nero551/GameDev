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

[AttributeUsage(AttributeTargets.Method)]
public class Encode(Type valueType) : Attribute
{
    public Type ValueType = valueType;
}

[AttributeUsage(AttributeTargets.Method)]
public class Decode(Type valueType) : Attribute
{
    public Type ValueType = valueType;
}