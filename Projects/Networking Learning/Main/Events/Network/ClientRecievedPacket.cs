using System;
using Godot;
using Godot.NativeInterop;


namespace Events;

public class ClientRecievedPacket(byte[] data) : Event
{
    public readonly byte[] Data = data;
}
