using System;
using System.Collections.Generic;
using Godot;

public class ServerRuntime : Runtime
{
    private  void AddProcessors()
    {
        Processor.Add<MovementProcessor>();
    }

    public override void Start()
    {
        Server.Start();
        AddProcessors();

        Entity entity = Entity.Create();
        entity.AddBlock<Blocks.Movement>();

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
