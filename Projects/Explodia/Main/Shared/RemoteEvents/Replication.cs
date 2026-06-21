using System;
using System.Collections.Generic;
using System.Reflection;
using Godot;
using Processors;

namespace RemoteEvents.Replication;
public class Replication : RemoteEvent
{
    private int ArrayLength;
    public List<ReplicationBox> ReplicationQueue = [];

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
            WriteObject(replicationBox.Value);
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
            object value = ReadObject();
            ReplicationQueue.Add(new ReplicationBox(entityId, blockId, fieldId, value));
        }
    }
}
