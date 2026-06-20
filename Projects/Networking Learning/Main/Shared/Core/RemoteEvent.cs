using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Blocks;
using Godot;

namespace RemoteEvents { }

public abstract class RemoteEvent() : Event
{
    public virtual int Flag { get; }

    public int SenderPeerId;
    public object[] DecodedData;

    public object[] Data;
    public List<byte> BufferList = [];
    protected byte[] BufferArray = [];
    private int ReadPos = 0;

    public static T Create<T>(params object[] data) where T : RemoteEvent, new()
    {
        T remoteEvent = new()
        {
            Data = data
        };
        return remoteEvent;
    }

    public static int ReadRemoteEventId(byte[] encodedData)
    {
        return BitConverter.ToInt32(encodedData, 0);
    }

    public virtual byte[] Encode()
    {
        WriteInt(NetworkService.RemoteEvents.GetByValue(this.GetType()));
        return CreateBytesArray();
    }
    public virtual void Decode()
    {
        ReadInt();
    }

    public void Fire()
    {
        EventService.Fire((dynamic)this);
    }

    public byte[] CreateBytesArray()
    {
        BufferArray = [.. BufferList];
        return BufferArray;
    }

    private void EnsureBytes(int size)
    {
        if (ReadPos + size > BufferArray.Length)
            throw new Exception("RemoteEvent read overflow");
    }

    //* Writing
    public void WriteBytes(byte[] bytes)
    {
        BufferList.AddRange(bytes);
    }
    public void WriteInt(int value)
    {
        BufferList.AddRange(BitConverter.GetBytes(value));
    }
    public void WriteFloat(float value)
    {
        BufferList.AddRange(BitConverter.GetBytes(value));
    }
    public void WriteBool(bool value)
    {
        BufferList.AddRange(BitConverter.GetBytes(value));
    }
    public void WriteString(string value)
    {
        WriteInt(value.Length);
        BufferList.AddRange(Encoding.ASCII.GetBytes(value));
    }

    public void WriteVector3(Vector3 vec3)
    {
        WriteFloat(vec3.X);
        WriteFloat(vec3.Y);
        WriteFloat(vec3.Z);
    }

    public void WriteVector2(Vector2 vec2)
    {
        WriteFloat(vec2.X);
        WriteFloat(vec2.Y);
    }

    public void WriteIntArray(int[] intArray)
    {
        WriteInt(intArray.Length);
        foreach (int i in intArray)
        {
            WriteInt(i);
        }
    }

    public void WriteBasis(Basis basis)
    {
        WriteVector3(basis.Column0);
        WriteVector3(basis.Column1);
        WriteVector3(basis.Column2);
        WriteVector3(basis.Row0);
        WriteVector3(basis.Row1);
        WriteVector3(basis.Row2);
        WriteVector3(basis.X);
        WriteVector3(basis.Y);
        WriteVector3(basis.Z);
    }

    public void WriteMovementBlock(Blocks.MovementBlock movementBlock)
    {
        WriteInt(movementBlock.EntityId);
        WriteVector2(movementBlock.MoveDirection);
        WriteFloat(movementBlock.Speed);
        WriteVector3(movementBlock.Velocity);
    }

    public void WriteTransformBlock(Blocks.TransformBlock transformBlock)
    {
        WriteInt(transformBlock.EntityId);
        WriteVector3(transformBlock.Position);
        WriteBasis(transformBlock.Basis);
    }


    //* Reading
    public int ReadInt()
    {
        EnsureBytes(4);
        int value = BitConverter.ToInt32(BufferArray, ReadPos);
        ReadPos += 4;
        return value;
    }
    public float ReadFloat()
    {
        EnsureBytes(4);
        float value = BitConverter.ToSingle(BufferArray, ReadPos);
        ReadPos += 4;
        return value;
    }
    public bool ReadBool()
    {
        EnsureBytes(1);
        bool value = BitConverter.ToBoolean(BufferArray, ReadPos);
        ReadPos++;
        return value;
    }
    public string ReadString()
    {
        int length = ReadInt();
        if (length > 0)
        {
            EnsureBytes(length);
            string value = Encoding.ASCII.GetString(BufferArray, ReadPos, length);
            ReadPos += length;
            return value;
        }
        return string.Empty;
    }

    public Vector3 ReadVector3()
    {
        EnsureBytes(12);
        return new Vector3(ReadFloat(), ReadFloat(), ReadFloat());
    }

    public Vector2 ReadVector2()
    {
        EnsureBytes(8);
        return new Vector2(ReadFloat(), ReadFloat());
    }

    public int[] ReadIntArray()
    {
        int length = ReadInt();
        if (length > 0)
        {
            EnsureBytes(length);
            int[] intArray = new int[length];
            for (int i = 0; i < length; i++)
            {
                intArray[i] = ReadInt();
            }
            return intArray;
        }
        return [];
    }

    public Basis ReadBasis()
    {
        return new Basis()
        {
            Column0 = ReadVector3(),
            Column1 = ReadVector3(),
            Column2 = ReadVector3(),
            Row0 = ReadVector3(),
            Row1 = ReadVector3(),
            Row2 = ReadVector3(),
            X = ReadVector3(),
            Y = ReadVector3(),
            Z = ReadVector3(),
        };

    }

    public Blocks.MovementBlock ReadMovementBlock()
    {
        return new MovementBlock() { EntityId = ReadInt(), MoveDirection = ReadVector2(), Speed = ReadFloat(), Velocity = ReadVector3() };
    }

    public Blocks.TransformBlock ReadTransformBlock()
    {
        return new Blocks.TransformBlock() { EntityId = ReadInt(), Position = ReadVector3(), Basis = ReadBasis() };
    }
}
