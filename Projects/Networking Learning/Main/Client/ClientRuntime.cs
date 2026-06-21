using System;
using System.Collections.Generic;
using Godot;

public class ClientRuntime : Runtime
{
    protected override void AddProcessors()
    {
        base.AddProcessors();
        Processor.Add<Processors.InputProcessor>();
    }

    public override void Start()
    {
        Client.Start();

        base.Start();
    }

    public override void Process(double delta)
    {
        Client.Process(delta);
        
        base.Process(delta);
    }

    public override void PhysicsProcess(double delta)
    {
        base.PhysicsProcess(delta);
    }
}
