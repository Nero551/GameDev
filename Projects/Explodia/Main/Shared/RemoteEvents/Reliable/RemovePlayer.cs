using Godot;

namespace RemoteEvents;

public class RemovePlayer : RemoteEvent
{
    public int UserId;

    public override int Flag => (int)ENetPacketPeer.FlagReliable;

    public override byte[] Encode()
    {
        base.Encode();

        WriteInt((int)Data[0]);

        return CreateBytesArray();
    }

    public override void Decode()
    {
        base.Decode();

        UserId = ReadInt();
    }
}
