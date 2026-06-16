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
        EventService.Subscribe<Events.ClientConnected>(TestMethod, Test2Method);
        EventService.Fire<Events.ClientConnected>(new Events.ClientConnected(5));
		EventService.Unsubscribe<Events.ClientConnected>(TestMethod,Test2Method);
        EventService.Fire<Events.ClientConnected>(new Events.ClientConnected(6));
    }

    void TestMethod(Events.ClientConnected @event)
    {
        GD.Print(@event.ClientId);
    }

    void Test2Method(Events.ClientConnected @event)
    {
        GD.Print("Nice");
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(double delta)
    {
    }
}
