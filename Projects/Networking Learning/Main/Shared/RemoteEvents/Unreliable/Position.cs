using System;
using System.Collections.Generic;
using System.Data.Common;
using Godot;

namespace RemoteEvents;

public class Position : RemoteEvent
{
    public int UserId;
    public Vector3 Vec3;

    public override int Flag => (int)ENetPacketPeer.FlagUnreliableFragment;

    public override byte[] Encode()
    {
        base.Encode();

        WriteInt((int)Data[0]);
        WriteVector3((Vector3)Data[1]);

        //* Writing Here
        return CreateBytesArray();
    }

    public override void Decode()
    {
        base.Decode();

        //* Reading Here
		UserId = ReadInt();
		Vec3 = ReadVector3();
    }
}


