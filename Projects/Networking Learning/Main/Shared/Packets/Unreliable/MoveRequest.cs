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
        //Writing Id
        WriteInt(NetworkService.IdPacketLookup[this.GetType()]);
        WriteFloat(((Vector2)Data[0]).X);
        WriteFloat(((Vector2)Data[0]).Y);

        //* Writing Here
        return CreateBytesArray();
    }

    public override object[] Decode()
    {
        //Skip id
        ReadInt();

        //* Reading Here
        object[] data = [ReadFloat(), ReadFloat()];
        return data;
    }

    public override void FireRemote(int senderPeerId, object[] decodedData)
    {
        base.FireRemote(senderPeerId, decodedData);
        EventService.Fire(new Events.Remote.MoveRequest(decodedData, senderPeerId));
    }
}

