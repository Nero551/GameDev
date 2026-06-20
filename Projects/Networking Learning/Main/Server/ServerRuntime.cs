using System;
using System.Collections.Generic;
using Godot;

public class ServerRuntime : Runtime
{
    protected override void AddProcessors()
    {
        base.AddProcessors();
        // Processor.Add<Processors.MovementProcessor>();
    }

    /*
    TODO- do this , also the new framework's name is Depths
    *  the plan is to seperate entities from nodes. nodes will just be visual representation.
    *   entities will contain components like Position,Velocity,Animation. we change those.
    *   nodes just take those values and apply to themselves
    */

    public override void Start()
    {

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
