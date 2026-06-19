using Godot;
using System;
using System.Collections.Generic;

public partial class ClientMain
{
    public static List<Processor> ClientProcessors = [];

    public static void AddProcessors()
    {
        Processor.Add<Processor>(ref ClientProcessors);
    }

    public static void Start()
    {
        Client.Start();

        ClientProcessors.ForEach(processor => processor.Start());
    }

    public static void Process(double delta)
    {
        ClientProcessors.ForEach(processor => processor.Process(delta));
    }

    public static void PhysicsProcess(double delta)
    {
        ClientProcessors.ForEach(processor => processor.PhysicsProcess(delta));

    }
}
