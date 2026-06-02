using Godot;
using Godot.Collections;

namespace PULib;

public static partial class JSONHelper
{
    public static Dictionary JSONToCSharp(string filePath)
    {
        var file = Godot.FileAccess.Open("res://" + filePath + ".json", Godot.FileAccess.ModeFlags.Read);

        if (file == null)
        {
            GD.PrintErr("Failed to open file: " + filePath);
            return new Dictionary();
        }

        string jsonString = file.GetAsText();
        var parsedData = Json.ParseString(jsonString);

        if (parsedData.VariantType == Variant.Type.Nil)
        {
            GD.PrintErr("Invalid JSON in file: " + filePath);
            return new Dictionary();
        }

        if (parsedData.VariantType != Variant.Type.Dictionary)
        {
            GD.PrintErr("JSON root is not a Dictionary: " + filePath);
            return new Dictionary();
        }

        return parsedData.AsGodotDictionary();
    }
}