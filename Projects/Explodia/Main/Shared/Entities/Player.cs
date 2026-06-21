using System;
using Godot;


namespace Entities;

public class Player : Entity
{
    protected override void Initialize()
    {
        AddBlock<Blocks.TransformBlock>();
        AddBlock<Blocks.MovementBlock>();
        AddBlock<Blocks.InputBlock>();

        if (NetworkService.IsClient())
        {
            World.Players.AddChild(ConnectTo(SceneService.CreateScene<CharacterBody3D>("Shared/Scenes/Player")));
        }
    }
}
