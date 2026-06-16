using System;
using Godot;


namespace Events;

public class ClientConnected(int clientId) : Event
{
    public readonly int ClientId = clientId;
}