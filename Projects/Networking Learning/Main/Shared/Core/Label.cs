using System;
using Godot;

public partial class Label : Godot.Label
{
    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        if (NetworkService.IsServer())
        {
            Text = "Server";
        }
        EventService.Subscribe<Events.Network.ConnectedToServer>((evnt) =>
        {
            if (NetworkService.IsClient())
            {
                Text = $"Client {Client.PeerId}";
            }
        });
    }


    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(double delta)
    {
    }
}
