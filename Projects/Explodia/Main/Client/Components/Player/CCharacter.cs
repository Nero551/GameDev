using Godot;
using System;

public partial class CCharacter : Component
{
    public Character Character;
    public void SpawnCharacter(string name)
    {
        if (Character == null)
        {
            PackedScene scene = GD.Load<PackedScene>("res://Main/Workspace/Character.tscn");
            Character = scene.Instantiate<Character>();
            Character.Name = name;
            Game.Characters.AddChild(Character);
        }
    }
}
