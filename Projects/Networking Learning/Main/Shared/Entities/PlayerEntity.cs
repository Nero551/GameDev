using System;
using Godot;


namespace Entities;

public class PlayerEntity : Entity
{
    protected override void Initialize()
    {
        Player player = SceneService.CreateScene<Player>("Shared/Scenes/player");
        Game.World.AddChild(player);
        AddBlock<Blocks.TransformBlock>();
        AddBlock<Blocks.MovementBlock>();
        ConnectTo(player);
    }
}
