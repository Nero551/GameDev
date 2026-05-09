using Godot;
using System;

public partial class CCharacter : Component
{
    public ECharacter Character;
    public void SpawnCharacter(string name)
    {
        if (Character == null)
        {
            PackedScene scene = GD.Load<PackedScene>("res://Main/Workspace/Character.tscn");
            Character = scene.Instantiate<ECharacter>();
            Character.Name = name;
            World.Characters.AddChild(Character);
        }
    }
}
