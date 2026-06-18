using System;
using System.Collections.Generic;
using Godot;


namespace Events.Remote;

public class ClientInfo : Remote
{
    public int UserId;
    public int PeerId;
    public Player Player;

    public ClientInfo(int senderPeerId, object[] decodedData)
    {
        DecodedData = decodedData;
        SenderPeerId = senderPeerId;

        UserId = (int)DecodedData[0];
        PeerId = (int)DecodedData[1];
    }
}
