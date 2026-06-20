using System;
using System.Collections.Generic;
using System.Reflection;
using Godot;
using Processors;

namespace RemoteEvents;

public class Replication : RemoteEvent
{
    private int ArrayLength;
    public List<ReplicationBox> ReplicationBoxes = [];

    public override int Flag => (int)ENetPacketPeer.FlagUnreliableFragment;

    public override byte[] Encode()
    {
        base.Encode();
        //* Writing Here
        WriteInt(((List<ReplicationBox>)Data[0]).Count);
        foreach (ReplicationBox replicationBox in (List<ReplicationBox>)Data[0])
        {
            WriteInt(replicationBox.EntityId);
            WriteInt(replicationBox.BlockId);
            WriteInt(replicationBox.FieldId);

            WriteInt(TypeToId[replicationBox.Value.GetType()]);
            switch (replicationBox.Value)
            {
                case int i: WriteInt(i); break;
                case float f: WriteFloat(f); break;
                case bool b: WriteBool(b); break;
                case string s: WriteString(s); break;
                case Vector2 v: WriteVector2(v); break;
                case Vector3 v: WriteVector3(v); break;
                case Basis b: WriteBasis(b); break;
            }
        }
        return CreateBytesArray();
    }

    public override void Decode()
    {
        base.Decode();

        //* Reading Here
        ArrayLength = ReadInt();
        for (int i = 0; i < ArrayLength; i++)
        {
            int entityId = ReadInt();
            int blockId = ReadInt();
            int fieldId = ReadInt();
            int typeId = ReadInt();
            object value;
            //TODO- make this dynamic too
            switch (typeId)
            {
                case 0:
                    value = ReadInt();
                    break;

                case 1:
                    value = ReadFloat();
                    break;

                case 2:
                    value = ReadBool();
                    break;

                case 3:
                    value = ReadString();
                    break;

                case 4:
                    value = ReadVector2();
                    break;

                case 5:
                    value = ReadVector3();
                    break;

                case 6:
                    value = ReadBasis();
                    break;

                default:
                    throw new Exception($"Unknown TypeId: {typeId}");
            }

            ReplicationBoxes.Add(new ReplicationBox(entityId, blockId, fieldId, value));
        }
    }
}


