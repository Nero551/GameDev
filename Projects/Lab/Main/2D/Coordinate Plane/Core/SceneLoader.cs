using Godot;
using System;

public partial class SceneLoader
{
    public static PackedScene Load(string path)
    {
        return GD.Load<PackedScene>($"res://Main/2D/Coordinate Plane/Scenes/{path}.tscn");
    }
}
