using Blocks;
using Godot;

namespace RemoteEvents;

public class MoveRequest : RemoteEvent
{
    public int EntityId;
    public Vector2 MoveDirection;

    public override int Flag => (int)ENetPacketPeer.FlagUnreliableFragment;

    public override byte[] Encode()
    {
        base.Encode();
        WriteInt((int)Data[0]);
        WriteVector2((Vector2)Data[1]);
        return CreateBytesArray();
    }

    public override void Decode()
    {
        base.Decode();
        EntityId = ReadInt();
        MoveDirection = ReadVector2();
    }
}
