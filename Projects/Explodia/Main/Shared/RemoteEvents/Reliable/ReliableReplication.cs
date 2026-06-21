using System;
using Godot;

namespace RemoteEvents.Replication;

public class ReliableReplication : Replication
{
    public override int Flag => (int)ENetPacketPeer.FlagReliable;
}


