using Godot;

namespace RemoteEvents;

public class MoveRequest : Packet
{
    public Vector2 Vec2;

    public override int Flag => (int)ENetPacketPeer.FlagUnreliableFragment;

    public override byte[] Encode()
    {
        base.Encode();

        WriteVector2((Vector2)Data[0]);

        return CreateBytesArray();
    }

    public override void Decode()
    {
        base.Decode();

        Vec2 = ReadVector2();
    }
}
