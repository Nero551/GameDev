using System;
using System.Collections.Generic;
using System.Data.Common;
using Godot;

namespace Packets;

public class Position : Packet
{

    public override int Flag => (int)ENetPacketPeer.FlagUnreliableFragment;

    public override byte[] Encode()
    {
        base.Encode();

        foreach (var item in Data)
        {
            GD.Print(item);
        }
        WriteInt((int)Data[0]);
        WriteVector3((Vector3)Data[1]);

        //* Writing Here
        return CreateBytesArray();
    }

    public override object[] Decode()
    {
        base.Decode();

        //* Reading Here
        object[] data = [ReadInt(), ReadVector3()];
        return data;
    }

    public override void FireRemote(int senderPeerId, object[] decodedData)
    {
        base.FireRemote(senderPeerId, decodedData);
        EventService.Fire(new Events.Remote.Position(decodedData, senderPeerId));
    }
}

