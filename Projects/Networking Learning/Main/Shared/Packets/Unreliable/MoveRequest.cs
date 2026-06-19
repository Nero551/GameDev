using System;
using System.Collections.Generic;
using System.Data.Common;
using Godot;

namespace Packets;

public class MoveRequest : Packet
{

    public override int Flag => (int)ENetPacketPeer.FlagUnreliableFragment;

    public override byte[] Encode()
    {
        base.Encode();
        WriteVector2((Vector2)Data[0]);

        //* Writing Here
        return CreateBytesArray();
    }

    public override object[] Decode()
    {
        base.Decode();

        //* Reading Here
        object[] data = [ReadVector2()];
        return data;
    }

    public override void FireRemote(int senderPeerId, object[] decodedData)
    {
        base.FireRemote(senderPeerId, decodedData);
        EventService.Fire(new Events.Remote.MoveRequest(decodedData, senderPeerId));
    }
}

