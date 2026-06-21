using System;
using System.Collections.Generic;
using Godot;
using RemoteEvents.Replication;

namespace Processors;

public class ReplicationProcessor : Processor
{
    readonly Dictionary<ReplicationMode, List<ReplicationBox>> ReplicationQueues = new() {
        {ReplicationMode.Reliable, []},
        {ReplicationMode.Unreliable, []}
    };

    public override void Start()
    {
        EventService.Subscribe<RemoteEvents.Replication.UnreliableReplication>(OnReplication);
        EventService.Subscribe<RemoteEvents.Replication.ReliableReplication>(OnReplication);
        base.Start();
    }

    double elapsed = 0;
    public override void Process(double delta)
    {
        if (!NetworkService.IsServer())
            return;
        elapsed += delta;
        if (elapsed < 0.1)
            return;

        elapsed = 0;
        base.Process(delta);

        var unreliable = ReplicationQueues[ReplicationMode.Unreliable];
        var reliable = ReplicationQueues[ReplicationMode.Reliable];
        if (reliable.Count != 0)
        {
            NetworkService.SendToAllClients<RemoteEvents.Replication.UnreliableReplication>(
                reliable);
            reliable.Clear();
        }
        if (unreliable.Count != 0)
        {
            NetworkService.SendToAllClients<RemoteEvents.Replication.ReliableReplication>(
                unreliable);
            unreliable.Clear();
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

            var replicatedFields = block.ReplicatedFields;
            var lastReplicatedFields = block.LastReplicatedFields;

            foreach (var replicatedFieldId in replicatedFields.Keys)
            {
                var replicatedField = replicatedFields[replicatedFieldId];
                var value = replicatedField.Field.GetValue(block);

                if (!lastReplicatedFields.TryGetValue(replicatedFieldId, out var old)
                    || !Equals(value, old))
                {
                    lastReplicatedFields[replicatedFieldId] = value;

                    ReplicationBox replicationBox = new(entity.Id, blockId, replicatedFieldId, value);
                    ReplicationQueues[replicatedField.Attribute.Mode].Add(replicationBox);
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
            replicatedField.Field.SetValue(block, replicationBox.Value);
        }
    }
}
