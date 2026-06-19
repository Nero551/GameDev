using System;
using Godot;


namespace Processors;
public class MovementProcessor : Processor
{
    Blocks.Movement movementBlock;

    public override void Start(Entity entity)
    {
        base.Start(entity);

        movementBlock = entity.GetBlock<Blocks.Movement>();
    }

    public override void Process(Entity entity, double delta)
    {
        base.Process(entity, delta);
        movementBlock.Speed += (float)delta;
        // GD.Print(movementBlock.Speed);
    }

    public override void PhysicsProcess(Entity entity, double delta)
    {
        base.PhysicsProcess(entity, delta);
    }

    public override bool HasRequiredBlocks(Entity entity)
    {
        return entity.HasBlock<Blocks.Movement>();
    }
}
