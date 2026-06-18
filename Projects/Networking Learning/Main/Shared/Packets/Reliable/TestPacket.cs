using System;
using System.Collections.Generic;
using System.Data.Common;
using Godot;

namespace Packets;

public class TestPacket : Packet
{

    public override int Flag => (int)ENetPacketPeer.FlagReliable;

    public override byte[] Encode()
    {
        //Writing Id
        WriteInt(NetworkService.IdPacketLookup[this.GetType()]);

        //* Writing Here
        WriteInt((int)Data[0]);
        return CreateBytesArray();
    }

    public override object[] Decode()
    {
        //Skip id
        ReadInt();

        //* Writing Here
        object[] data = [ReadInt()];
        return data;
    }
}
