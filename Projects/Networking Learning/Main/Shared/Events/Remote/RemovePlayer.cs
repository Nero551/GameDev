using System;
using System.Collections.Generic;
using Godot;
using Packets;


namespace Events.Remote;

public class RemovePlayer : Remote
{
    public int UserId;
    public RemovePlayer(object[] decodedData, int senderPeerId)
    {
        DecodedData = decodedData;
        SenderPeerId = senderPeerId;

        UserId = (int)DecodedData[0];
    }
}

