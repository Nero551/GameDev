using System;
using System.Collections.Generic;
using Godot;
using Packets;


namespace Events.Remote;

public class Position : Remote
{
    public int UserId;
    public Vector3 Vec3;
    public Position(object[] decodedData, int senderPeerId)
    {
        DecodedData = decodedData;
        SenderPeerId = senderPeerId;

        UserId = (int)DecodedData[0];
        Vec3 = (Vector3)DecodedData[1];
    }
}

