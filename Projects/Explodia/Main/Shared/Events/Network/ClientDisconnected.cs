using System;
using Godot;


namespace Events.Network;

public class ClientDisconnected(int peerId) : Event
{
    public readonly int PeerId = peerId;
}
