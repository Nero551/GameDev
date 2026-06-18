using System;
using System.Collections.Generic;
using Godot;


namespace Events.Remote;

public class ClientInfo : Remote
{
    public int UserId;

    public ClientInfo(int senderPeerId, object[] decodedData)
    {
        DecodedData = decodedData;
        SenderPeerId = senderPeerId;
        UserId = (int)DecodedData[1];
    }
}
