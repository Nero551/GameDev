using System;
using System.Collections.Generic;
using Godot;

public static class ServerMain
{
    public static List<Processor> ServerProcessors = [];

    public static void AddProcessors()
    {
        Processor.Add<Processor>(ref ServerProcessors);
    }

    public static void Start()
    {
        Server.Start();

        ServerProcessors.ForEach(processor => processor.Start());
    }

    public static void Process(double delta)
    {
		ServerProcessors.ForEach(processor => processor.Process(delta));
    }

    public static void PhysicsProcess(double delta)
    {
        ServerProcessors.ForEach(processor => processor.PhysicsProcess(delta));

    }
}
