using System;
using System.Text;

class Packet
{
    public List<byte> BufferList = [];
    private byte[] BufferArray = [];
    private int ReadPos = 0;

    public byte[] CreateBytesArray()
    {
        BufferArray = BufferList.ToArray();
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
}