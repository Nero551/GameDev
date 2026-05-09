using Godot;
using System;

public interface IPlayerMovable : Interface
{
    ECharacter Character {get;}
    SpringArm3D SpringArm {get;}
}
