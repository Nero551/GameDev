using System;
using Godot;


namespace Events;

public class ClientDisconnected(int peerId) : Event
{
    public readonly int PeerId = peerId;
}
