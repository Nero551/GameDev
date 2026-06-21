using System;
using System.Collections.Generic;
using System.Reflection;
using Godot;

namespace Blocks;

/// <summary>
/// Base class for all entity block in the Depths framework.
/// </summary>
/// <remarks>
/// Blocks are data containers attached to entities.
/// They support replication via fields marked with [Replicated].
/// </remarks>
/// 
public abstract class Block
{
    /// <summary>
    /// Stores the last known replicated values for change detection.
    /// Key = replicated field ID.
    /// </summary>
    /// 
    public Dictionary<int, object> LastReplicatedFields = [];

    /// <summary>
    /// Metadata for fields marked with [Replicated].
    /// Key = field ID, Value = Field + Attribute metadata.
    /// </summary>
    /// 
    public Dictionary<int, ReplicatedField> ReplicatedFields = [];

    /// <summary>
    /// ID of the entity this block belongs to.
    /// </summary>
    /// 
    public int EntityId;
}