using System;
using System.Collections.Generic;
using System.Data.Common;
using Godot;

namespace Packets;

public class CreatePlayer : Packet
{

	public override int Flag => (int)ENetPacketPeer.FlagReliable;

	public override byte[] Encode()
	{
        base.Encode();
		//* Writing Here
		WriteInt((int)Data[0]);
		return CreateBytesArray();
	}

	public override object[] Decode()
	{
        base.Decode();

        //* Reading Here
        object[] data = [ReadInt()];
		return data;
	}

	public override void FireRemote(int senderPeerId, object[] decodedData)
	{
		base.FireRemote(senderPeerId, decodedData);
		EventService.Fire(new Events.Remote.CreatePlayer(decodedData,senderPeerId));
	}
}

