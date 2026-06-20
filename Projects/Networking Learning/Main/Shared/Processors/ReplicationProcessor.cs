using System;
using System.Collections.Generic;
using System.Reflection;
using Godot;
using RemoteEvents.Replication;

namespace Processors;

public class ReplicationProcessor : Processor
{
    double elapsed = 0;
    readonly List<ReplicationBox> UnreliableReplicationQueue = [];
    public List<ReplicationBox> ReliableReplicationQueue = [];

    public override void Start()
    {
        EventService.Subscribe<RemoteEvents.Replication.UnreliableReplication>(OnReplication);
        EventService.Subscribe<RemoteEvents.Replication.ReliableReplication>(OnReplication);
        base.Start();
    }

    public override void Process(double delta)
    {
        if (!NetworkService.IsServer())
            return;
        elapsed += delta;
        if (elapsed < 0.1)
            return;

        elapsed = 0;
        base.Process(delta);

        if (UnreliableReplicationQueue.Count != 0)
        {
            NetworkService.SendToAllClients<RemoteEvents.Replication.UnreliableReplication>(UnreliableReplicationQueue);
            UnreliableReplicationQueue.Clear();
        }

        if (ReliableReplicationQueue.Count != 0)
        {
            NetworkService.SendToAllClients<RemoteEvents.Replication.ReliableReplication>(UnreliableReplicationQueue);
            ReliableReplicationQueue.Clear();
        }
    }

    public override void ProcessEntities(Entity entity, double delta)
    {
        base.ProcessEntities(entity, delta);

        foreach (int blockId in entity.Blocks.Keys)
        {
            var block = entity.GetBlock(blockId);
            if (block == null)
                continue;

            foreach (var replicatedFieldId in block.ReplicatedFields.Keys)
            {
                var field = block.ReplicatedFields[replicatedFieldId];
                var value = field.GetValue(block);

                if (!block.LastReplicatedFields.TryGetValue(replicatedFieldId, out var old)
                    || !Equals(value, old))
                {
                    block.LastReplicatedFields[replicatedFieldId] = value;

                    ReplicationBox replicationBox = new(entity.Id, blockId, replicatedFieldId, value);
                    var attribute = field.GetCustomAttribute<Replicated>();

                    if (attribute.Mode == ReplicationMode.Reliable)
                    {
                        ReliableReplicationQueue.Add(replicationBox);
                    }
                    else if (attribute.Mode == ReplicationMode.Unreliable)
                    {
                        UnreliableReplicationQueue.Add(replicationBox);
                    }
                }
            }
        }
    }

    void OnReplication(RemoteEvents.Replication.Replication evnt)
    {
        foreach (ReplicationBox replicationBox in evnt.ReplicationQueue)
        {
            var entity = Game.Runtime.Entities[replicationBox.EntityId];
            var block = entity.GetBlock(replicationBox.BlockId);
            var replicatedField = block.ReplicatedFields[replicationBox.FieldId];
            replicatedField.SetValue(block, replicationBox.Value);
        }
    }
}
