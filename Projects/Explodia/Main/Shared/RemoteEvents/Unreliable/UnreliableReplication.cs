using System;
using Godot;

namespace RemoteEvents.Replication;

public class UnreliableReplication : Replication
{
	public override int Flag => (int)ENetPacketPeer.FlagUnreliableFragment;
}


