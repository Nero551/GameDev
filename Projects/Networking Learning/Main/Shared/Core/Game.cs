using System;
using Godot;

public partial class Game : Node3D
{
    public static Node3D World;
    // Called when the node enters the scene tree for the first time.
    public override void _EnterTree()
    {
        World = this;
        NetworkService.Init();

        if (NetworkService.IsServer())
        {
            ServerMain.Start();
        }
        else
        {
            ClientMain.Start();
        }
    }

    //*Note: u can add this to the launch args of the server to make it disable rendering:
    //* godot --headless Server

    public override void _Process(double delta)
    {
        base._Process(delta);

        if (NetworkService.IsServer())
        {
            ServerMain.Process(delta);
        }
        else
        {
            ClientMain.Process(delta);
        }
    }

    public override void _PhysicsProcess(double delta)
    {
        base._PhysicsProcess(delta);

        if (NetworkService.IsServer())
        {
            ServerMain.PhysicsProcess(delta);
        }
        else
        {
            ClientMain.PhysicsProcess(delta);
        }
    }
}
