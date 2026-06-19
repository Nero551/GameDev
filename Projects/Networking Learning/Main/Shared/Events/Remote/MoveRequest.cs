using System;
using System.Collections.Generic;
using Godot;
using Packets;


namespace Events.Remote;

public class MoveRequest : Remote
{
	public Vector2 Vec2;
	public MoveRequest(object[] decodedData,int senderPeerId)
	{
		DecodedData = decodedData;
		SenderPeerId = senderPeerId;

		Vec2 = (Vector2)DecodedData[0];
	}
}

