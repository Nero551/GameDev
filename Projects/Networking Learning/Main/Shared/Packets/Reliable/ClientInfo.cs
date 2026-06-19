using System;
using System.Collections.Generic;
using System.Data.Common;
using Godot;

namespace Packets;

public class ClientInfo : Packet
{

    public override int Flag => (int)ENetPacketPeer.FlagReliable;

    public override byte[] Encode()
    {
        base.Encode();
        //* Writing Here
        Server.ClientInfo clientInfo = Data[0] as Server.ClientInfo;
        WriteInt(clientInfo.UserId);
        WriteInt(clientInfo.PeerId);
        WriteIntArray((int[])Data[1]);
        // WriteInt(clientInfo.Peer);
        return CreateBytesArray();
    }

    public override object[] Decode()
    {
        base.Decode();

        //* Writing Here
        object[] data = [ReadInt(), ReadInt(),ReadIntArray()];
        return data;
    }

    public override void FireRemote(int senderPeerId, object[] decodedData)
    {
        base.FireRemote(senderPeerId, decodedData);
        EventService.Fire(new Events.Remote.ClientInfo(senderPeerId, decodedData));
    }
}
