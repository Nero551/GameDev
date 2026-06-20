using System;
using System.Collections.Generic;
using System.Reflection;
using Godot;


namespace Blocks;

public abstract class Block
{
    public Dictionary<int, object> LastReplicatedFields = [];
    public BiDictionary<int, FieldInfo> ReplicatedFields = new();

    public int Id;
    public int EntityId;
}
