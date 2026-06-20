using System;
using Blocks;
using Godot;
using RemoteEvents;


namespace Processors;

public class MovementProcessor : Processor
{
    public override bool HasRequiredBlocks(Entity entity)
    {
        return entity.HasBlock<Blocks.MovementBlock, Blocks.TransformBlock>();
    }

    public override void Init()
    {
        EventService.Subscribe<RemoteEvents.MoveRequest>(OnMoveRequest);
    }

    public override void Start(Entity entity)
    {
        base.Start(entity);
    }

    public override void Process(Entity entity, double delta)
    {
        base.Process(entity, delta);
    }

    double elapsed = 0;
    public override void PhysicsProcess(Entity entity, double delta)
    {
        base.PhysicsProcess(entity, delta);
        var movementBlock = entity.GetBlock<Blocks.MovementBlock>();
        var transformBlock = entity.GetBlock<Blocks.TransformBlock>();

        movementBlock.Velocity.X = Mathf.MoveToward(movementBlock.Velocity.X, 0, movementBlock.Speed);
        movementBlock.Velocity.Z = Mathf.MoveToward(movementBlock.Velocity.Z, 0, movementBlock.Speed);
        
        if (movementBlock.MoveDirection != Vector2.Zero)
        {
            Vector3 direction = (
                new Vector3(movementBlock.MoveDirection.X, 0, -movementBlock.MoveDirection.Y)
                ).Normalized();

            if (direction != Vector3.Zero)
            {
                movementBlock.Velocity.X = direction.X * movementBlock.Speed;
                movementBlock.Velocity.Z = direction.Z * movementBlock.Speed;
            }
        }

        transformBlock.Position += movementBlock.Velocity * (float)delta;

        elapsed += delta;
        if (elapsed >= 0.1)
        {
            elapsed = 0;
            NetworkService.SendToAllClients<RemoteEvents.Position>(entity.Id, transformBlock.Position);
        }
    }

    void OnMoveRequest(RemoteEvents.MoveRequest evnt)
    {
        var movementBlock = Game.Runtime.Entities[evnt.EntityId].GetBlock<Blocks.MovementBlock>();
        movementBlock.MoveDirection = evnt.MoveDirection;
    }
}
