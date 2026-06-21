using System;
using System.Collections.Generic;
using Godot;

public class ServerRuntime : Runtime
{
    protected override void AddProcessors()
    {
        base.AddProcessors();
        Processor.Add<Processors.MovementProcessor>();
    }

    public override void Start()
    {
        Server.Start();

        base.Start();
    }

    public override void Process(double delta)
    {
        Server.Process(delta);

        base.Process(delta);
    }

    public override void PhysicsProcess(double delta)
    {
        base.PhysicsProcess(delta);
    }
}
