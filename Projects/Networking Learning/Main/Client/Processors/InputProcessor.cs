using System;
using Blocks;
using Godot;


namespace Processors;

public class InputProcessor : Processor
{
    public override void Init()
    {
        EventService.Subscribe<RemoteEvents.Position>(OnPosition);
        base.Init();
    }

    public override bool HasRequiredBlocks(Entity entity)
    {
        return entity.HasBlock<Blocks.InputBlock, Blocks.MovementBlock>();
    }

    public override void Start(Entity entity)
    {
        base.Start(entity);
    }

    public override void Process(Entity entity, double delta)
    {
        base.Process(entity, delta);

        var movementBlock = entity.GetBlock<Blocks.MovementBlock>();

        movementBlock.MoveDirection = Input.GetVector("Left", "Right", "Back", "Forward");

        NetworkService.SendToServer<RemoteEvents.MoveRequest>(entity.Id, movementBlock.MoveDirection);

        var node = entity.GetNode<CharacterBody3D>();
        var target = entity.GetBlock<TransformBlock>().Position;
        node.Position = node.Position.Lerp(target, 0.05f);
    }

    void OnPosition(RemoteEvents.Position evnt)
    {
        Entity entity = Game.Runtime.Entities[evnt.EntityId];
        entity.GetBlock<Blocks.TransformBlock>().Position = evnt.Vec3;
    }
}
