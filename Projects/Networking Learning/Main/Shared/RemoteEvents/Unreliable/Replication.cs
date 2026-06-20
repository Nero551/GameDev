using System;
using System.Reflection;
using Godot;

namespace RemoteEvents;

public class Replication : RemoteEvent
{
    private int TypeId;
    public int EntityId;
    public int BlockId;
    public int FieldId;
    public object Value;

    public override int Flag => (int)ENetPacketPeer.FlagUnreliableFragment;

    public override byte[] Encode()
    {
        base.Encode();
        //* Writing Here
        WriteInt((int)Data[0]);
        WriteInt((int)Data[1]);
        WriteInt((int)Data[2]);

        TypeId = TypeToId[Data[3].GetType()];
        WriteInt(TypeId);
        switch (Data[3])
        {
            case int i: WriteInt(i); break;
            case float f: WriteFloat(f); break;
            case bool b: WriteBool(b); break;
            case string s: WriteString(s); break;
            case Vector2 v: WriteVector2(v); break;
            case Vector3 v: WriteVector3(v); break;
            case Basis b: WriteBasis(b); break;
        }

        return CreateBytesArray();
    }

    public override void Decode()
    {
        base.Decode();

        //* Reading Here
        EntityId = ReadInt();
        BlockId = ReadInt();
        FieldId = ReadInt();

        TypeId = ReadInt();
        switch (TypeId)
        {
            case 0:
                Value = ReadInt();
                return;

            case 1:
                Value = ReadFloat();
                return;

            case 2:
                Value = ReadBool();
                return;

            case 3:
                Value = ReadString();
                return;

            case 4:
                Value = ReadVector2();
                return;

            case 5:
                Value = ReadVector3();
                return;

            case 6:
                Value = ReadBasis();
                return;

            default:
                throw new Exception($"Unknown TypeId: {TypeId}");
        }
        throw new Exception($"Value Type Doesn't Exist For Replication Decoding {Value.GetType().Name}");
    }
}


