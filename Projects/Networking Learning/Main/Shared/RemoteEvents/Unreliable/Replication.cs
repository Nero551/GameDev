using System;
using Godot;

namespace RemoteEvents;
public class Replication : RemoteEvent
{

	public override int Flag => (int)ENetPacketPeer.FlagUnreliableFragment;

	public override byte[] Encode()
	{
		base.Encode();
		//* Writing Here
		return CreateBytesArray();
	}

	public override void Decode()
	{
		base.Decode();

		//* Reading Here
	}
}


