using System;
using Godot;

namespace Blocks;

public class TransformBlock : Block
{
    public Basis Basis;
    [Replicated] public Vector3 Position;


}
