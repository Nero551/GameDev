using Godot;

public class AudioService : Service
{
    public static void PlaySound(string filepath, Node parent)
    {
        AudioStreamPlayer sound = new AudioStreamPlayer();

        sound.Stream = GD.Load<AudioStream>($"res://Main/{filepath}");

        parent.AddChild(sound);

        sound.Play();
        sound.Finished += sound.QueueFree;
    }

    public static void PlaySpatialSound(string filepath, Node parent)
    {
        AudioStreamPlayer3D sound = new AudioStreamPlayer3D();

        sound.Stream = GD.Load<AudioStream>($"res://Main/{filepath}");

        parent.AddChild(sound);

        sound.Play();
        sound.Finished += sound.QueueFree;
    }
}