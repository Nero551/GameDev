using System;
using System.Collections.Generic;
using System.Reflection;
using Godot;

namespace Processors;

public class ReplicationProcessor : Processor
{
    double elapsed = 0;
    private readonly List<ReplicationBox> ReplicationBoxes = [];

    public override void Start()
    {
        EventService.Subscribe<RemoteEvents.Replication>(OnReplication);
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

        if (ReplicationBoxes.Count != 0)
        {
            GD.Print(ReplicationBoxes);
            NetworkService.SendToAllClients<RemoteEvents.Replication>(ReplicationBoxes);
            ReplicationBoxes.Clear();
        }
    }

    public override void ProcessEntities(Entity entity, double delta)
    {
        base.ProcessEntities(entity, delta);

        foreach (int blockId in entity.Blocks.GetAllKeys())
        {
            var block = entity.GetBlock(blockId);
            if (block == null)
                continue;

            foreach (var replicatedFieldId in block.ReplicatedFields.GetAllKeys())
            {
                var field = block.ReplicatedFields.GetByKey(replicatedFieldId);
                var value = field.GetValue(block);

                if (!block.LastReplicatedFields.TryGetValue(replicatedFieldId, out var old)
                    || !Equals(value, old))
                {
                    block.LastReplicatedFields[replicatedFieldId] = value;

                    ReplicationBox replicationBox = new(entity.Id, blockId, replicatedFieldId, value);
                    ReplicationBoxes.Add(replicationBox);
                }
            }
        }
    }

    void OnReplication(RemoteEvents.Replication evnt)
    {
        foreach (ReplicationBox replicationBox in evnt.ReplicationBoxes)
        {
            var entity = Game.Runtime.Entities[replicationBox.EntityId];
            var block = entity.GetBlock(replicationBox.BlockId);
            var replicatedField = block.ReplicatedFields.GetByKey(replicationBox.FieldId);
            replicatedField.SetValue(block, replicationBox.Value);
        }
    }
}
