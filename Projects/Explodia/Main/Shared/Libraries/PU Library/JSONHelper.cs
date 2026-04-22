using Godot;
using Godot.Collections;

public static partial class PULib
{
	public static Dictionary JSONToCSharp(string FilePath)
	{
		var file = FileAccess.Open("res://" + FilePath + ".json", FileAccess.ModeFlags.Read);

		if (file != null)
		{
			var jsonString = file.GetAsText();
			var parsedData = Json.ParseString(jsonString);
			var data = parsedData.AsGodotDictionary();

			return data;
		}
		return new Godot.Collections.Dictionary();
	}
}
