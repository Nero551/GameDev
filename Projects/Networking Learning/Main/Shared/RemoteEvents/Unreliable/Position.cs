using System;
using System.Collections.Generic;
using System.Data.Common;
using Blocks;
using Godot;

namespace RemoteEvents;

public class Position : RemoteEvent
{
    public int EntityId;
    public Vector3 Vec3;

    public override int Flag => (int)ENetPacketPeer.FlagUnreliableFragment;

    public override byte[] Encode()
    {
        base.Encode();        
        //* Writing Here
        WriteInt((int)Data[0]);
        WriteVector3((Vector3)Data[1]);
        return CreateBytesArray();
    }

    public override void Decode()
    {
        base.Decode();

        //* Reading Here
        EntityId = ReadInt();
        Vec3 = ReadVector3();
    }
}


