using System;
using System.Collections.Generic;
using Godot;

public class ClientRuntime : Runtime
{
    protected override void AddProcessors()
    {
        base.AddProcessors();
        Processor.Add<Processors.MovementProcessor>();
    }

    public override void Start()
    {
        Client.Start();
        AddProcessors();

        Entity.Create<Entities.PlayerEntity>();
        Entity.Create<Entities.PlayerEntity>().GetBlock<Blocks.MovementBlock>().Speed = 10f;

        base.Start();
    }

    public override void Process(double delta)
    {
        base.Process(delta);
    }

    public override void PhysicsProcess(double delta)
    {
        base.PhysicsProcess(delta);
    }
}
