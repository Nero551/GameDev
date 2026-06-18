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
        //Writing Id
        WriteInt(NetworkService.IdPacketLookup[this.GetType()]);
        WriteFloat(((Vector3)Data[0]).X);
        WriteFloat(((Vector3)Data[0]).Y);
        WriteFloat(((Vector3)Data[0]).Z);

        //* Writing Here
        return CreateBytesArray();
    }

    public override object[] Decode()
    {
        //Skip id
        ReadInt();

        //* Reading Here
        object[] data = [ReadFloat(), ReadFloat(), ReadFloat()];
        return data;
    }

    public override void FireRemote(int senderPeerId, object[] decodedData)
    {
        base.FireRemote(senderPeerId, decodedData);
        EventService.Fire(new Events.Remote.Position(decodedData, senderPeerId));
    }
}

