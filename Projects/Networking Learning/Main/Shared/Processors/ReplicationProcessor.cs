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
        if (NetworkService.IsServer())
            return;

        elapsed += delta;
        if (elapsed < 0.1)
            return;
        elapsed = 0;

        foreach (KeyValuePair<Type, List<FieldInfo>> pair in entity.ReplicatedFields)
        {
            var blockType = pair.Key;
            var fieldList = pair.Value;
            var block = entity.GetBlock(blockType);

            foreach (var field in fieldList)
            {
                var value = field.GetValue(block);
                if (!entity.LastReplicatedFieldValues.ContainsKey(field))
                {
                    if (!Equals(value, entity.LastReplicatedFieldValues[field]))
                    {
                        //add to packet
                        entity.LastReplicatedFieldValues[field] = value;
                        GD.Print(field.Name);

                        NetworkService.SendToAllClients<RemoteEvents.Replication>(
                            entity.Id, block.Id, block.ReplicatedFields.GetByValue(field), value);
                    }
                }
            }
        }
    }

    void OnReplication(RemoteEvents.Replication evnt)
    {

    }
}
