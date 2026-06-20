using System;
using Blocks;
using Godot;


namespace Processors;

public class MovementProcessor : Processor
{
    public override bool HasRequiredBlocks(Entity entity)
    {
        return entity.HasBlock<Blocks.MovementBlock, Blocks.TransformBlock>();
    }

    public override void Start(Entity entity)
    {
        base.Start(entity);
    }

    public override void Process(Entity entity, double delta)
    {
        base.Process(entity, delta);
    }

    public override void PhysicsProcess(Entity entity, double delta)
    {
        base.PhysicsProcess(entity, delta);
        var movementBlock = entity.GetBlock<Blocks.MovementBlock>();
        var transformBlock = entity.GetBlock<Blocks.TransformBlock>();

        movementBlock.MoveDirection = Input.GetVector("Left", "Right", "Back", "Forward");

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
        entity.GetNode<CharacterBody3D>().Position = transformBlock.Position;

        movementBlock.Velocity.X = Mathf.MoveToward(movementBlock.Velocity.X, 0, movementBlock.Speed);
        movementBlock.Velocity.Z = Mathf.MoveToward(movementBlock.Velocity.Z, 0, movementBlock.Speed);
    }
}
