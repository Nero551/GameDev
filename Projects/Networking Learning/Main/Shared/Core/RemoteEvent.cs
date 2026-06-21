using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
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
    private readonly List<byte> BufferList = [];
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
    [Encode(typeof(int))]
    protected void WriteInt(int value)
    {
        BufferList.AddRange(BitConverter.GetBytes(value));
    }

    [Encode(typeof(float))]
    protected void WriteFloat(float value)
    {
        BufferList.AddRange(BitConverter.GetBytes(value));
    }

    [Encode(typeof(bool))]
    protected void WriteBool(bool value)
    {
        BufferList.AddRange(BitConverter.GetBytes(value));
    }

    [Encode(typeof(string))]
    protected void WriteString(string value)
    {
        WriteInt(value.Length);
        BufferList.AddRange(Encoding.ASCII.GetBytes(value));
    }

    [Encode(typeof(Vector3))]
    protected void WriteVector3(Vector3 vec3)
    {
        WriteFloat(vec3.X);
        WriteFloat(vec3.Y);
        WriteFloat(vec3.Z);
    }

    [Encode(typeof(Vector2))]
    protected void WriteVector2(Vector2 vec2)
    {
        WriteFloat(vec2.X);
        WriteFloat(vec2.Y);
    }

    [Encode(typeof(int[]))]
    protected void WriteIntArray(int[] intArray)
    {
        WriteInt(intArray.Length);
        foreach (int i in intArray)
            WriteInt(i);
    }

    [Encode(typeof(Basis))]
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

    [Decode(typeof(int))]
    protected int ReadInt()
    {
        EnsureBytes(4);
        int value = BitConverter.ToInt32(BufferArray, ReadPos);
        ReadPos += 4;
        return value;
    }

    [Decode(typeof(float))]
    protected float ReadFloat()
    {
        EnsureBytes(4);
        float value = BitConverter.ToSingle(BufferArray, ReadPos);
        ReadPos += 4;
        return value;
    }

    [Decode(typeof(bool))]
    protected bool ReadBool()
    {
        EnsureBytes(1);
        bool value = BitConverter.ToBoolean(BufferArray, ReadPos);
        ReadPos += 1;
        return value;
    }

    [Decode(typeof(string))]
    protected string ReadString()
    {
        int length = ReadInt();

        if (length <= 0)
            return string.Empty;

        EnsureBytes(length);
        string value = Encoding.ASCII.GetString(BufferArray, ReadPos, length);
        ReadPos += length;
        return value;
    }

    [Decode(typeof(Vector3))]
    protected Vector3 ReadVector3()
    {
        return new Vector3(ReadFloat(), ReadFloat(), ReadFloat());
    }

    [Decode(typeof(Vector2))]
    protected Vector2 ReadVector2()
    {
        return new Vector2(ReadFloat(), ReadFloat());
    }

    [Decode(typeof(int[]))]
    protected int[] ReadIntArray()
    {
        int length = ReadInt();

        if (length <= 0)
            return [];

        int[] arr = new int[length];

        for (int i = 0; i < length; i++)
            arr[i] = ReadInt();

        return arr;
    }

    [Decode(typeof(Basis))]
    protected Basis ReadBasis()
    {
        return new Basis
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

    protected void WriteObject(object value)
    {
        int typeId = TypeToId[value.GetType()];
        WriteInt(typeId);
        IdToCoder[typeId].Encode.Invoke(this, [value]);
    }

    protected object ReadObject()
    {
        int typeId = ReadInt();
        return IdToCoder[typeId].Decode.Invoke(this, null);
    }

    public static void RegisterEnDecoding()
    {
        int nextTypeId = 0;
        foreach (MethodInfo method in typeof(RemoteEvent).GetMethods(BindingFlags.NonPublic | BindingFlags.Instance).OrderBy(m => m.Name))
        {
            if (Attribute.IsDefined(method, typeof(Encode)) || Attribute.IsDefined(method, typeof(Decode)))
            {
                int typeId;
                Coder coder;
                Type valueType = Attribute.IsDefined(method, typeof(Encode)) ?
                    method.GetCustomAttribute<Encode>().ValueType : valueType = method.GetCustomAttribute<Decode>().ValueType;

                if (TypeToId.ContainsKey(valueType))
                {
                    typeId = TypeToId[valueType];
                    coder = IdToCoder[typeId];
                }
                else
                {
                    typeId = nextTypeId;
                    nextTypeId++;
                    TypeToId.Add(valueType, typeId);

                    coder = new();
                    IdToCoder.Add(typeId, coder);
                }

                if (Attribute.IsDefined(method, typeof(Encode)))
                {
                    coder.Encode = method;
                }
                if (Attribute.IsDefined(method, typeof(Decode)))
                {
                    coder.Decode = method;
                }
            }
        }
    }

    protected class Coder
    {
        public MethodInfo Encode;
        public MethodInfo Decode;
    }

    protected static readonly Dictionary<int, Coder> IdToCoder = [];
    protected static readonly Dictionary<Type, int> TypeToId = [];
}
