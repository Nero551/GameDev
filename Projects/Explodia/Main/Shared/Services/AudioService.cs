using Godot;

public class AudioService : Service
{
    public static void PlaySound(string filepath, Node parent)
    {
        var sound = new AudioStreamPlayer() { Stream = GD.Load<AudioStream>($"res://Main/{filepath}") };
        parent.AddChild(sound);

        sound.Play();
        sound.Finished += sound.QueueFree;
    }

    public static void PlaySpatialSound(string filepath, Node parent)
    {
        var sound = new AudioStreamPlayer3D() { Stream = GD.Load<AudioStream>($"res://Main/{filepath}") };
        parent.AddChild(sound);

        sound.Play();
        sound.Finished += sound.QueueFree;
    }
}