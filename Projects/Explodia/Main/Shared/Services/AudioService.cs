using Godot;

public static class AudioService
{
    public static void PlaySound(string filepath, Node parent)
    {

        var sound = new AudioStreamPlayer() { Stream = GD.Load<AudioStream>($"res://Main/{filepath}") };
        parent.AddChild(sound);

        if (filepath.Contains("Music"))
        {
            sound.Bus = "Music";
        }
        else if (filepath.Contains("SFX"))
        {
            sound.Bus = "SFX";
        }

        sound.Play();
        sound.Finished += sound.QueueFree;
    }

    public static void PlaySpatialSound(string filepath, Node parent)
    {
        var sound = new AudioStreamPlayer3D() { Stream = GD.Load<AudioStream>($"res://Main/{filepath}") };
        if (filepath.Contains("Music"))
        {
            sound.Bus = "Music";
        }
        else if (filepath.Contains("SFX"))
        {
            sound.Bus = "SFX";
        }
        parent.AddChild(sound);

        sound.Play();
        sound.Finished += sound.QueueFree;
    }
}