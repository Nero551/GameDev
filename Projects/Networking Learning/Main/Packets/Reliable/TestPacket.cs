using System;
using System.Collections.Generic;
using System.Data.Common;
using Godot;

namespace Packets;

public class TestPacket : Packet
{

    public override int Id => 1;
    public override int Flag => (int)ENetPacketPeer.FlagReliable;

    public override byte[] Encode()
    {
        //Writing Id
        WriteInt(Id);
        
        //* Writing Here
        WriteInt((int)Data[0]);
        return CreateBytesArray();
    }

    public override List<Object> Decode()
    {
        //Skip id
        ReadInt();

        //* Writing Here
        List<Object> data = [ReadInt()];
        return data;
    }
}
