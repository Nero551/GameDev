using System;
using Godot;


namespace Events.Network;

public class ClientConnected(int peerId) : Event
{
    public readonly int PeerId = peerId;
}
