using System;
using System.Collections.Generic;
using Godot;
using Packets;


namespace Events.Remote;

public class CreatePlayer : Remote
{
    public int UserId;
    public CreatePlayer(object[] decodedData, int senderPeerId)
    {
        DecodedData = decodedData;
        SenderPeerId = senderPeerId;

        UserId = (int)DecodedData[0];
    }
}

