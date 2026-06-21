

public class ReplicationBox(int entityId, int blockId, int fieldId, object value)
{
    public int EntityId => entityId;
    public int BlockId => blockId;
    public int FieldId => fieldId;
    public object Value => value;
}