using System;
using System.Collections.Generic;
using System.Reflection;
using Godot;

namespace Processors;

public class ReplicationProcessor : Processor
{
    public override void Init()
    {
        EventService.Subscribe<RemoteEvents.Replication>(OnReplication);
    }

    public override void Start(Entity entity)
    {
        base.Start(entity);
    }

    double elapsed = 0;
    public override void Process(Entity entity, double delta)
    {
        base.Process(entity, delta);
        if (!NetworkService.IsServer())
            return;

        elapsed += delta;
        if (elapsed < 0.1)
            return;
        elapsed = 0;

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
                    NetworkService.SendToAllClients<RemoteEvents.Replication>(
                        entity.Id, block.Id, replicatedFieldId, value);
                }
            }
        }
    }

    void OnReplication(RemoteEvents.Replication evnt)
    {
        GD.Print(evnt.EntityId,evnt.BlockId,evnt.FieldId,evnt.Value);
        var entity = Game.Runtime.Entities[evnt.EntityId];
        var block = entity.GetBlock(evnt.BlockId);
        var replicatedField = block.ReplicatedFields.GetByKey(evnt.FieldId);
        replicatedField.SetValue(block, evnt.Value);
    }
}
