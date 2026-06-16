using System;
using System.Collections.Generic;
using Godot;

namespace Packets;

public class TestPacket : Packet
{
    public override byte[] Encode()
    {
        Flag = (int)ENetPacketPeer.FlagReliable;
        ID = 1;
        WriteInt(1);
        WriteInt(5);
        return CreateBytesArray();
    }

    public override List<Object> Decode()
    {
        //Dont Read packet id when decoding.
        List<Object> data = [ReadInt()];
        return data;
    }
}
