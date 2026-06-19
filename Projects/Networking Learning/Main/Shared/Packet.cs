using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Godot;

namespace Packets { }

public abstract class Packet()
{
    public virtual int Flag { get; }

    public object[] Data;
    public List<byte> BufferList = [];
    protected byte[] BufferArray = [];
    private int ReadPos = 0;

    public static T Create<T>(params object[] data) where T : Packet, new()
    {
        T packet = new()
        {
            Data = data
        };
        return packet;
    }

    public static int ReadPacketId(byte[] encodedData)
    {
        return BitConverter.ToInt32(encodedData, 0);
    }

    public virtual void FireRemote(int senderPeerId, object[] decodedData)
    {

    }
    public virtual byte[] Encode()
    {
        WriteInt(NetworkService.IdPacketLookup[this.GetType()]);
        return CreateBytesArray();
    }
    public virtual object[] Decode()
    {
        ReadInt();
        return [];
    }

    public byte[] CreateBytesArray()
    {
        BufferArray = [.. BufferList];
        return BufferArray;
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


    //* Reading
    public int ReadInt()
    {
        if (BufferList.Count > ReadPos)
        {
            int value = BitConverter.ToInt32(BufferArray, ReadPos);
            ReadPos += 4;
            return value;
        }
        throw new Exception("Couldn't Read Value");
    }
    public float ReadFloat()
    {
        if (BufferList.Count > ReadPos)
        {
            float value = BitConverter.ToSingle(BufferArray, ReadPos);
            ReadPos += 4;
            return value;
        }
        throw new Exception("Couldn't Read Value");
    }
    public bool ReadBool()
    {
        if (BufferList.Count > ReadPos)
        {
            bool value = BitConverter.ToBoolean(BufferArray, ReadPos);
            ReadPos++;
            return value;
        }
        throw new Exception("Couldn't Read Value");
    }
    public string ReadString()
    {
        if (BufferList.Count > ReadPos)
        {
            int length = ReadInt();
            if (length > 0)
            {
                string value = Encoding.ASCII.GetString(BufferArray, ReadPos, length);
                ReadPos += length;
                return value;
            }
        }
        throw new Exception("Couldn't Read Value");
    }

    public Vector3 ReadVector3()
    {
        return new Vector3(ReadFloat(), ReadFloat(), ReadFloat());
    }

    public Vector2 ReadVector2()
    {
        return new Vector2(ReadFloat(), ReadFloat());
    }

    public int[] ReadIntArray()
    {
        
        int length = ReadInt();
        int[] intArray = [length];
        for (int i = 0; i < length - 1; i++)
        {
            intArray[i] = ReadInt();
        }

        return intArray;
    }
}