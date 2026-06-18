using System;
using System.Collections.Generic;
using Godot;
using Packets;


namespace Events.Remote;

public class Position : Remote
{
    public Vector3 Vec3;
    public Position(object[] decodedData, int senderPeerId)
    {
        DecodedData = decodedData;
        SenderPeerId = senderPeerId;
        Vec3 = new Vector3((float)DecodedData[0], (float)DecodedData[1], (float)DecodedData[2]);
    }
}

