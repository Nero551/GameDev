using System;
using System.Collections.Generic;
using Godot;

public class ClientRuntime : Runtime
{
    private void AddProcessors()
    {
        // Processor.Add<MovementProcessor>();
    }

    public override void Start()
    {
        Client.Start();
        AddProcessors();

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
