using System;
using Godot;


namespace Events;

public class ClientConnected(int peerId) : Event
{
    public readonly int PeerId = peerId;
}
