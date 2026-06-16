using System;
using Godot;

public partial class Game : Node3D
{
    public static Node3D game;
    // Called when the node enters the scene tree for the first time.
    public override void _EnterTree()
    {
        game = this;
    }

    public override void _Ready()
    {
        base._Ready();
        EventService.Subscribe<Events.ClientConnected>(TestMethod);
        EventService.Fire<Events.ClientConnected>(new Events.ClientConnected(5));

    }

    void TestMethod(Events.ClientConnected @event)
    {
        GD.Print(@event.ClientId);
        GD.Print("Nice");
        // GD.Print(clientConnected.ClientId);
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(double delta)
    {
    }
}
