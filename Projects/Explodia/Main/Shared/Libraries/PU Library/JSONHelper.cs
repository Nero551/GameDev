using Godot;
using Godot.Collections;

public static partial class PULib
{
	public static Dictionary JSONToCSharp(string FilePath)
	{
		var file = FileAccess.Open("res://" + FilePath + ".json", FileAccess.ModeFlags.Read);

		if (file != null)
		{
			string jsonString = file.GetAsText();
			var parsedData = Json.ParseString(jsonString);
			Dictionary data = parsedData.AsGodotDictionary();

			return data;
		}
		return new Godot.Collections.Dictionary();
	}
}
