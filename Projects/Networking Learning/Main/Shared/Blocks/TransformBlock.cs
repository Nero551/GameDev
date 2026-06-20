using Godot;
using System;

namespace Blocks;
public  class TransformBlock : Block
{
    [Replicated] public Basis Basis;
	[Replicated] public Vector3 Position;
    

}
