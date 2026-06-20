using System;
using System.Collections.Generic;
using System.Reflection;
using Godot;


namespace Blocks;

public abstract class Block
{
    public BidirectionalDictionary<int, FieldInfo> ReplicatedFields = new();

    public int Id;
    public int EntityId;
}
