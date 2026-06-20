using System;
using System.Collections.Generic;
using System.Reflection;
using Godot;


namespace Blocks;

public abstract class Block
{
    public Dictionary<int, object> LastReplicatedFields = [];
    public Dictionary<int, FieldInfo> ReplicatedFields = [];

    public int EntityId;
}
