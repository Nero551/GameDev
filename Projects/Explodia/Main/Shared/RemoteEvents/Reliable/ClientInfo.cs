using Godot;

namespace RemoteEvents;

public class ClientInfo : RemoteEvent
{
    public int UserId;
    public int PeerId;
    public int[] PlayerIds;

    public override int Flag => (int)ENetPacketPeer.FlagReliable;

    public override byte[] Encode()
    {
        base.Encode();

        Server.ClientInfo clientInfo = Data[0] as Server.ClientInfo;
        WriteInt(clientInfo.UserId);
        WriteInt(clientInfo.PeerId);
        WriteIntArray((int[])Data[1]);

        return CreateBytesArray();
    }

    public override void Decode()
    {
        base.Decode();
        UserId = ReadInt();
        PeerId = ReadInt();
        PlayerIds = ReadIntArray();
    }
}
