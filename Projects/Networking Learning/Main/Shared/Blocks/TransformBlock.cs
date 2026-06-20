using System;
using Godot;

namespace Blocks;

public class TransformBlock : Block
{
    public Basis Basis;
    [Replicated(ReplicationMode.Unreliable)] public Vector3 Position;


}
