using System;
using Godot;


namespace Events;

public class ServerRecievedPacket(int clientId, byte[] data) : Event
{
    public readonly int ClientId = clientId;
    public readonly byte[] Data = data;
}
