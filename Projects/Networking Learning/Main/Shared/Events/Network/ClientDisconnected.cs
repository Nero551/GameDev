using System;
using Godot;


namespace Events;

public class ClientDisconnected(int clientId) : Event
{
    public readonly int ClientId = clientId;
}
