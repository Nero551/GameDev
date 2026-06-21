using System;
using Godot;


namespace Events.Network;

public class RecievedPacket(byte[] data, int senderPeerId = 0) : Event
{
    public readonly int SenderPeerId = senderPeerId;
    public readonly byte[] Data = data;
}
