using System;
using System.Collections.Generic;
using Godot;

public class SceneService
{
    public static Dictionary<string, PackedScene> CachedScenes = [];

    public static T CreateScene<T>(string filepath) where T : Node
    {
        PackedScene scene;

        if (CachedScenes.ContainsKey(filepath))
        {
            scene = CachedScenes[filepath];
        }
        else
        {
            scene = GD.Load<PackedScene>($"res://Main/{filepath}.tscn");
            CachedScenes[filepath] = scene;
        }

        if (scene == null)
        {
            throw new Exception($"Couldn't Load Scene: {filepath}");
        }

        return scene.Instantiate<T>();
    }
}
