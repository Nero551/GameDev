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
    protected object[] DecodedData;

    protected object[] Data;
    private List<byte> BufferList = [];
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

    protected void EnsureBytes(int size)
    {
        if (ReadPos + size > BufferArray.Length)
            throw new Exception("RemoteEvent read overflow");
    }

    //* Writing
    public void WriteBytes(byte[] bytes)
    {
        BufferList.AddRange(bytes);
    }
    protected void WriteInt(int value)
    {
        BufferList.AddRange(BitConverter.GetBytes(value));
    }
    protected void WriteFloat(float value)
    {
        BufferList.AddRange(BitConverter.GetBytes(value));
    }
    protected void WriteBool(bool value)
    {
        BufferList.AddRange(BitConverter.GetBytes(value));
    }
    protected void WriteString(string value)
    {
        WriteInt(value.Length);
        BufferList.AddRange(Encoding.ASCII.GetBytes(value));
    }

    protected void WriteVector3(Vector3 vec3)
    {
        WriteFloat(vec3.X);
        WriteFloat(vec3.Y);
        WriteFloat(vec3.Z);
    }

    protected void WriteVector2(Vector2 vec2)
    {
        WriteFloat(vec2.X);
        WriteFloat(vec2.Y);
    }

    protected void WriteIntArray(int[] intArray)
    {
        WriteInt(intArray.Length);
        foreach (int i in intArray)
        {
            WriteInt(i);
        }
    }

    protected void WriteBasis(Basis basis)
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

    //* Reading
    protected int ReadInt()
    {
        EnsureBytes(4);
        int value = BitConverter.ToInt32(BufferArray, ReadPos);
        ReadPos += 4;
        return value;
    }
    protected float ReadFloat()
    {
        EnsureBytes(4);
        float value = BitConverter.ToSingle(BufferArray, ReadPos);
        ReadPos += 4;
        return value;
    }
    protected bool ReadBool()
    {
        EnsureBytes(1);
        bool value = BitConverter.ToBoolean(BufferArray, ReadPos);
        ReadPos++;
        return value;
    }
    protected string ReadString()
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

    protected Vector3 ReadVector3()
    {
        EnsureBytes(12);
        return new Vector3(ReadFloat(), ReadFloat(), ReadFloat());
    }

    protected Vector2 ReadVector2()
    {
        EnsureBytes(8);
        return new Vector2(ReadFloat(), ReadFloat());
    }

    protected int[] ReadIntArray()
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

    protected Basis ReadBasis()
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

    protected static readonly Dictionary<Type, int> TypeToId = new()
{
    { typeof(int), 0 },
    { typeof(float), 1 },
    { typeof(bool), 2 },
    { typeof(string), 3 },
    { typeof(Vector2), 4 },
    { typeof(Vector3), 5 },
    { typeof(Basis), 6 },
};
}
